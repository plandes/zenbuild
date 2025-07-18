# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import sys
import recommonmark  # must be imported, even though not used by name
from recommonmark.transform import AutoStructify

# give Sphinx access Python source code
{%- for path in config.doc.api_config.source_dirs %}
sys.path.insert(0, '{{ path }}')
{%- endfor %}


# -- Project information -----------------------------------------------------
project = '{{ config.project.short_description }}'
author = '{{ config.author.name }}'
copyright = '{{ date.year }} {{ config.author.name }}'

# the full version, including alpha/beta/rc tags
version = '{{ project.change_log.entries[-1].version.simple }}'
release = version


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    # doc string processing
    'sphinx.ext.autodoc',
    'sphinx_autodoc_typehints',
    'sphinx.ext.intersphinx',
    'sphinx.ext.napoleon',

    # add link to view code
    'sphinx.ext.viewcode',
    # add view code button
    'sphinx_copybutton',

    # inheritance diagrams
    'btd.sphinx.graphviz',
    'btd.sphinx.inheritance_diagram',

    # markdown
    'recommonmark',
    # auto-generate section labels.
    'sphinx.ext.autosectionlabel',
]

# autodoc extension configuration
autodoc_default_options = {
    # Add __init__ methods (see functions maybe_skip_member and setup)
    'special-members': True,
}

# make more inheritance diagrams more readable
inheritance_node_attrs = dict(
    color='grey60',
    fontcolor='red',
    fontsize=14,
    penwidth=2,
)
inheritance_edge_attrs = dict(
    color='grey60',
    fontcolor='red',
    penwidth=2,
)
inheritance_graph_attrs = dict(
    bgcolor='grey8',
    rankdir="TB", size='"9.0, 8.0"',
    ratio='compress')

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['api/{{ config.project.domain }}.rst']

# map to other sphinx docs
intersphinx_mapping = {
{%- for package, pkg in config.doc.api_config.intersphinx_mapping.items() %}
  {%- for mod in pkg['modules'] %}
    '{{mod}}': ('{{ pkg['url'].format(package=package, **env) }}', None),
  {%- endfor %}
{%- endfor %}
}

# The master toctree document.
master_doc = 'top'


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'furo'

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
# html_static_path = ['_static']

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# turn off cert checks
tls_verify = False

# markdown

# Prefix document path to section labels, otherwise autogenerated labels would
# look like 'heading' rather than 'path/to/file:heading'
autosectionlabel_prefix_document = True

# docroot to use for linking documentation
link_doc_root = 'https://github.com/{{ config.github.user }}/{{ config.project.domain }}/{{config.project.name }}/tree/master/doc'


def maybe_skip_member(app, what, name, obj, skip, options):
    """Skip only non-init methods.  This filters out all cluttering attributes such
    as ``__dataclass_parameters`` and ``__abstractmethods__``, which show up
    after setting ``special-members=True`` in ``autodoc_default_options``.

    :see: :obj:`autodoc_default_options`

    """
    if not skip and (what == 'class') and (name != '__init__') \
       and (name.startswith('__') and name.endswith('__')):
        return True
    return skip


def setup(app):
    app.add_config_value('recommonmark_config', {
        'url_resolver': lambda url: link_doc_root + url,
        'enable_auto_toc_tree': True,
        'auto_toc_tree_section': 'Contents',
        'auto_toc_maxdepth': 4,
        'autosectionlabel_maxdepth': 4,
        'enable_math': True,
        'enable_inline_math': True,
    }, True)
    app.add_transform(AutoStructify)
    app.connect('autodoc-skip-member', maybe_skip_member)
