{{ config.project.short_description }}
{{ '=' * (config.project.short_description | length) }}
{{ config.project.long_description }}

.. toctree::
   :maxdepth: 3
   :glob:

   Overview <index.md>
   doc/*
   API Reference <api.rst>
   Contributing <CONTRIBUTING.md>


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
