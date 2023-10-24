# violet-soup
This overlay acts as upstream for violet-funk. It contains volatile ebuilds that should not be used on a production system.

This overlay is also not available in repositories.xml. If you want to add it to your system, have `app-portage/eselect-repository` installed and use the following command:

``sudo eselect repository add violet-soup git https://github.com/MagelessMayhem/violet-soup && sudo emerge --sync violet-soup``
