#!/usr/bin/env python

import os
import sys
import argparse
from jinja2 import Environment, FileSystemLoader, exceptions


def render_template(template_file, output_file, context):
    """
    Renders a Jinja2 template with a given context and writes it to an output file.
    """
    try:
        # Get the directory containing the template file
        # This allows Jinja2 to find the template correctly
        template_dir = os.path.dirname(os.path.abspath(template_file))
        template_name = os.path.basename(template_file)

        # Set up the Jinja2 environment
        # The FileSystemLoader loads templates from the file system
        env = Environment(loader=FileSystemLoader(template_dir))

        # Load the template
        template = env.get_template(template_name)

        # Render the template with the provided context
        rendered_content = template.render(context)

        # Write the rendered content to the output file
        with open(output_file, "w") as f:
            f.write(rendered_content)

        print(f"Successfully rendered template '{template_file}' to '{output_file}'")

    except exceptions.TemplateNotFound:
        print(f"Error: Template not found at '{template_file}'", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """
    Main function to parse arguments and initiate template rendering.
    """
    parser = argparse.ArgumentParser(
        description="Render a Jinja2 template using environment variables."
    )

    # Define command-line arguments
    parser.add_argument("template_file", help="Path to the input Jinja2 template file.")
    parser.add_argument("output_file", help="Path for the output rendered file.")

    args = parser.parse_args()

    # Use all environment variables as the context
    # We pass `dict(os.environ)` to create a simple dictionary
    # that Jinja2 can easily work with.
    context = dict(os.environ)

    render_template(args.template_file, args.output_file, context)


if __name__ == "__main__":
    main()
