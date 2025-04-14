import argparse
import pdfplumber
import re
import os

# example usage: python3 vectorTableGenerator.py --input vector_table.pdf --start-page 0 --end-page 3  --column 3

def sanitize_identifier(name):
    """Sanitize string to be a valid C identifier."""
    name = name.strip()
    name = re.sub(r'\W|^(?=\d)', '_', name)
    return name

def extract_column_from_pdf(pdf_path, column_index=0, start_page=0, end_page=None):
    """Extract the specified column across multiple pages of a PDF, keeping all entries including '-'."""
    entries = []
    with pdfplumber.open(pdf_path) as pdf:
        total_pages = len(pdf.pages)
        end_page = end_page if end_page is not None else total_pages
        for page_num in range(start_page, min(end_page, total_pages)):
            table = pdf.pages[page_num].extract_table()
            if table:
                for row in table[1:]:  # Skip header row
                    if row and len(row) > column_index:
                        entry = row[column_index]
                        if entry is not None:  # keep everything, even if it's '-' or whitespace
                            entries.append(entry.strip())
                        else:
                            entries.append('')  # explicitly preserve empty cells
    return entries

def generate_c_file(function_names, output_path, skip_first_dash_mode):
    """Generate a C file with function alias declarations and definitions."""
    with open(output_path, 'w') as f:
        f.write('// Auto-generated vector table stubs\n\n')

        vectors_parsed = 0
        # Function prototypes with alias
        for name in function_names:
             if name.strip() != "-":
                func_name = sanitize_identifier(name)
                f.write(f'void {func_name}_Handler(void) __attribute__((weak, alias("Default_Handler")));\n')
                vectors_parsed = vectors_parsed + 1

        f.write('\n')

        f.write(f'uint32_t vectors[] __attribute__((section(".isr_vector"))) = {{\n')
        f.write(f'STACK_START,\n')

        # Determine whether to skip the first dash
        first_dash_index = None
        first_real_index = None

        if skip_first_dash_mode:
            for i, name in enumerate(function_names):
                if name.strip() == "-" and first_dash_index is None:
                    first_dash_index = i
                elif name.strip() != "-" and first_real_index is None:
                    first_real_index = i

            skip_first_dash = (
                first_dash_index is not None and
                (first_real_index is None or first_dash_index < first_real_index)
            )
        else:
            skip_first_dash = False

        dash_skipped = False

        for i, name in enumerate(function_names):
            if name.strip() == "-":
                if skip_first_dash and not dash_skipped and i == first_dash_index:
                    dash_skipped = True
                    continue  # Skip the first "-"
                f.write('0,\n')  # All other "-" entries become 0
            else:
                func_name = sanitize_identifier(name)
                f.write(f'(uint32_t)&{func_name}_Handler,\n')

        f.write('};\n\n')

        print("Parsed ", vectors_parsed, " vectors")
def main():
    parser = argparse.ArgumentParser(description="Generate vector table stubs from a multi-page PDF.")
    parser.add_argument('--input', '-i', required=True, help='Path to the input PDF file.')
    parser.add_argument('--output', '-o', default='generated_functions.c', help='Path to output C file.')
    parser.add_argument('--func-names', '-c', type=int, default=0, help='Column index to extract (0-based).')
    parser.add_argument('--start-page', '-s', type=int, default=0, help='Start page index (0-based).')
    parser.add_argument('--end-page', '-e', type=int, default=None, help='End page index (0-based, exclusive). Leave blank to go to end.')
    parser.add_argument('--skip-first-dash', '-f', type=int, default=0, help='Skips the first dash dash coming before a non string in a table to replace with STACK_START')

    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"❌ Error: File '{args.input}' not found.")
        return

    function_names = extract_column_from_pdf(
        args.input,
        column_index=args.func_names,
        start_page=args.start_page,
        end_page=args.end_page,
    )
    if not function_names:
        print("⚠️ No valid entries found in the selected column or page range.")
        return

    generate_c_file(function_names, args.output,args.skip_first_dash)
    print(f"✅ C file generated: {args.output}")

if __name__ == "__main__":
    main()
