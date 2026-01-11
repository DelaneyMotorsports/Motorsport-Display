# Configuration file for the Sphinx documentation builder.
#
# Reikon Dash Documentation Configuration
# Integrates Doxygen (C++ API) with Sphinx (User/Developer Guides)
#
# This file follows the Sphinx 5.0+ configuration format
# For full documentation, see: https://www.sphinx-doc.org/en/master/usage/configuration.html
#
# Author: Kevin Delaney
# Company: Delaney Motorsports, LLC
# Date: January 10, 2026

import os
import sys
from datetime import datetime

# -- Path setup --------------------------------------------------------------

# Add project root to Python path for custom extensions
sys.path.insert(0, os.path.abspath('..'))

# -- Project information -----------------------------------------------------

project = 'Reikon Dash'
copyright = f'{datetime.now().year}, Delaney Motorsports, LLC'
author = 'Kevin Delaney'

# The full version, including alpha/beta/rc tags
release = '1.0.0'
version = '1.0'

# -- General configuration ---------------------------------------------------

# Extensions to enable
extensions = [
    'breathe',                    # Doxygen integration
    'sphinx.ext.autodoc',         # Auto-generate docs from docstrings
    'sphinx.ext.napoleon',        # Google/NumPy docstring support
    'sphinx.ext.viewcode',        # Add links to highlighted source code
    'sphinx.ext.todo',            # TODO directive support
    'sphinx.ext.coverage',        # Documentation coverage analysis
    'sphinx.ext.intersphinx',     # Link to other Sphinx documentation
    'sphinx.ext.graphviz',        # Graphviz diagram support
    'sphinx.ext.mathjax',         # Math equations (for algorithms)
    'myst_parser',                # Markdown support
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'doxygen']

# The suffix(es) of source filenames.
source_suffix = {
    '.rst': 'restructuredtext',
    '.md': 'markdown',
}

# The master toctree document.
master_doc = 'index'

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.
html_theme = 'sphinx_rtd_theme'  # Read the Docs theme

# Theme options
html_theme_options = {
    'logo_only': False,
    'display_version': True,
    'prev_next_buttons_location': 'bottom',
    'style_external_links': True,
    'navigation_depth': 4,
    'collapse_navigation': False,
    'sticky_navigation': True,
    'includehidden': True,
    'titles_only': False
}

# Add any paths that contain custom static files (such as style sheets)
html_static_path = ['_static']

# Custom sidebar templates
html_sidebars = {
    '**': [
        'globaltoc.html',
        'relations.html',
        'sourcelink.html',
        'searchbox.html',
    ]
}

# HTML options
html_title = f"{project} v{version} Documentation"
html_short_title = project
html_logo = None  # TODO: Add company logo
html_favicon = None  # TODO: Add favicon

# -- Options for LaTeX output ------------------------------------------------

latex_engine = 'pdflatex'

latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '10pt',
    'preamble': r'''
        \usepackage{charter}
        \usepackage[defaultsans]{lato}
        \usepackage{inconsolata}
    ''',
    'figure_align': 'htbp',
}

# Grouping the document tree into LaTeX files
latex_documents = [
    (master_doc, 'ReikonDash.tex', 'Reikon Dash Documentation',
     'Kevin Delaney, Delaney Motorsports LLC', 'manual'),
]

# -- Options for manual page output ------------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
man_pages = [
    (master_doc, 'reikondash', 'Reikon Dash Documentation',
     [author], 1)
]

# -- Options for Texinfo output ----------------------------------------------

# Grouping the document tree into Texinfo files
texinfo_documents = [
    (master_doc, 'ReikonDash', 'Reikon Dash Documentation',
     author, 'ReikonDash', 'Professional motorsport telemetry display system.',
     'Miscellaneous'),
]

# -- Options for Epub output -------------------------------------------------

# Bibliographic Dublin Core info.
epub_title = project
epub_author = author
epub_publisher = 'Delaney Motorsports, LLC'
epub_copyright = copyright

# -- Extension configuration -------------------------------------------------

# -- Breathe configuration (Doxygen integration) -----------------------------

breathe_projects = {
    "Reikon Dash": os.path.abspath("doxygen/xml")
}

breathe_default_project = "Reikon Dash"

breathe_default_members = ('members', 'undoc-members')

# Doxygen output directory (must match Doxyfile GENERATE_XML output)
breathe_projects_source = {
    "Reikon Dash": (os.path.abspath("../app"), ["platform", "model", "services"])
}

# -- Napoleon settings (Google/NumPy docstring support) ----------------------

napoleon_google_docstring = True
napoleon_numpy_docstring = True
napoleon_include_init_with_doc = True
napoleon_include_private_with_doc = False
napoleon_include_special_with_doc = True
napoleon_use_admonition_for_examples = True
napoleon_use_admonition_for_notes = True
napoleon_use_admonition_for_references = True
napoleon_use_ivar = False
napoleon_use_param = True
napoleon_use_rtype = True
napoleon_type_aliases = None

# -- Intersphinx configuration -----------------------------------------------

# Links to external Sphinx documentation
intersphinx_mapping = {
    'python': ('https://docs.python.org/3', None),
    'qt': ('https://doc.qt.io/qt-6/', None),
}

# -- Todo extension configuration --------------------------------------------

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = True
todo_emit_warnings = False

# -- Graphviz configuration --------------------------------------------------

graphviz_output_format = 'svg'

# -- MyST Parser configuration (Markdown support) ----------------------------

myst_enable_extensions = [
    "amsmath",        # Math equations
    "colon_fence",    # ::: code fences
    "deflist",        # Definition lists
    "dollarmath",     # $...$ inline math
    "fieldlist",      # Field lists
    "html_admonition",  # HTML-style admonitions
    "html_image",     # HTML img tags
    "linkify",        # Auto-detect URLs
    "replacements",   # Text replacements
    "smartquotes",    # Smart quotes
    "strikethrough",  # ~~text~~
    "substitution",   # Variable substitution
    "tasklist",       # Task lists [ ] [x]
]

myst_heading_anchors = 3  # Auto-generate anchors for headings up to h3

# -- Custom configuration ----------------------------------------------------

# Automotive standards compliance notices
rst_prolog = """
.. |MISRA| replace:: MISRA C++:2023
.. |AUTOSAR| replace:: AUTOSAR C++14
.. |CERT| replace:: SEI CERT C++
.. |ISO26262| replace:: ISO 26262:2018
.. |ISO21434| replace:: ISO/SAE 21434:2021
.. |ASPICE| replace:: Automotive SPICE
.. |company| replace:: Delaney Motorsports, LLC
.. |author| replace:: Kevin Delaney
"""

# Add safety/security badges
safety_notice = """
.. note::
   This component is classified as **ASIL-B** (ISO 26262).
   All code must meet automotive safety standards.
"""

security_notice = """
.. warning::
   This component handles untrusted data (CAN bus).
   Follow secure coding practices (ISO/SAE 21434).
"""

# -- Build options -----------------------------------------------------------

# Warn about all references where the target cannot be found
nitpicky = True

# Show warnings as errors (strict mode)
# Uncomment for CI/CD: nitpicky = True

# Suppress specific warnings
suppress_warnings = [
    'ref.citation',  # Suppress citation warnings
]

# -- Advanced options --------------------------------------------------------

# Number figures and tables automatically
numfig = True
numfig_format = {
    'figure': 'Figure %s',
    'table': 'Table %s',
    'code-block': 'Listing %s',
    'section': 'Section %s'
}

# -- Metadata ----------------------------------------------------------------

html_context = {
    'display_github': True,
    'github_user': 'DelaneyMotorsports',
    'github_repo': 'Motorsport-Display',
    'github_version': 'dev',
    'conf_py_path': '/reikon-dash/docs/',
}

# Version info display
html_show_sourcelink = True
html_show_sphinx = True
html_show_copyright = True

# -- Custom CSS and JavaScript -----------------------------------------------

def setup(app):
    """Custom Sphinx setup"""
    # Add custom CSS
    app.add_css_file('custom.css')

    # Add automotive standards badges
    app.add_config_value('safety_notice', safety_notice, 'html')
    app.add_config_value('security_notice', security_notice, 'html')

# -- Build commands ----------------------------------------------------------

# To build documentation:
#   sphinx-build -b html docs docs/_build
#
# To build PDF:
#   sphinx-build -b latex docs docs/_build/latex
#   cd docs/_build/latex && make
#
# To check for broken links:
#   sphinx-build -b linkcheck docs docs/_build
#
# To generate coverage report:
#   sphinx-build -b coverage docs docs/_build

# -- Documentation standards -------------------------------------------------

# ISO/IEC 26514:2022 compliance:
# - Clear structure (introduction, body, conclusion)
# - Consistent terminology (glossary)
# - Task-oriented (how-to guides)
# - Accessibility (alt text, semantic markup)
# - Version control (revision history)
#
# Target audiences:
# 1. End users (racing teams, engineers)
# 2. Developers (contributors, maintainers)
# 3. Safety engineers (certification auditors)
# 4. Security analysts (penetration testers)
