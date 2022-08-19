
add_library(Qt5::QMngPlugin MODULE IMPORTED)


_populate_Gui_plugin_properties(QMngPlugin RELEASE "imageformats/qmng.dll" FALSE)

list(APPEND Qt5Gui_PLUGINS Qt5::QMngPlugin)
set_property(TARGET Qt5::Gui APPEND PROPERTY QT_ALL_PLUGINS_imageformats Qt5::QMngPlugin)
set_property(TARGET Qt5::QMngPlugin PROPERTY QT_PLUGIN_TYPE "imageformats")
set_property(TARGET Qt5::QMngPlugin PROPERTY QT_PLUGIN_EXTENDS "")
set_property(TARGET Qt5::QMngPlugin PROPERTY QT_PLUGIN_CLASS_NAME "QMngPlugin")
