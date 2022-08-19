
add_library(Qt5::QJp2Plugin MODULE IMPORTED)


_populate_Gui_plugin_properties(QJp2Plugin RELEASE "imageformats/qjp2.dll" FALSE)

list(APPEND Qt5Gui_PLUGINS Qt5::QJp2Plugin)
set_property(TARGET Qt5::Gui APPEND PROPERTY QT_ALL_PLUGINS_imageformats Qt5::QJp2Plugin)
set_property(TARGET Qt5::QJp2Plugin PROPERTY QT_PLUGIN_TYPE "imageformats")
set_property(TARGET Qt5::QJp2Plugin PROPERTY QT_PLUGIN_EXTENDS "")
set_property(TARGET Qt5::QJp2Plugin PROPERTY QT_PLUGIN_CLASS_NAME "QJp2Plugin")
