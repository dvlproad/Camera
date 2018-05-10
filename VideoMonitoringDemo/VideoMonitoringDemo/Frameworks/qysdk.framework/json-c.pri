INCLUDEPATH += $$PWD

HEADERS += \
    $$PWD/json.h \
    $$PWD/json_inttypes.h \
    $$PWD/json_object.h \
    $$PWD/json_object_private.h \
    $$PWD/json_tokener.h \
    $$PWD/json_util.h \
    $$PWD/arraylist.h \
    $$PWD/config.h \
    $$PWD/debug.h \
    $$PWD/linkhash.h \
    $$PWD/printbuf.h \
    $$PWD/json_mm_internal.h

SOURCES += \
    $$PWD/json_object.c \
    $$PWD/json_tokener.c \
    $$PWD/json_util.c \
    $$PWD/arraylist.c \
    $$PWD/debug.c \
    $$PWD/linkhash.c \
    $$PWD/printbuf.c \
    $$PWD/json_mm_internal.c
