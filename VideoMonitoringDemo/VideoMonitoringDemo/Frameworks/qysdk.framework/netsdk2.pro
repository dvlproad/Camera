TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.c \
    task_test.c \
    kernel_test.c \
    object_test.c \
    socket_test.c \
    map_test.c \
    socket_mutil_test.c \
    session_test.c \
    netsdk_test.c \
    relay_test.c \
    device_test.c \
    ffmpeg_text.c

include(../library/libevent/libevent.pri)
include(../library/json-c/json-c.pri)
include(../library/des/des.pri)
include(../library/jemalloc/jemalloc.pri)
include(../library/ffmpeg/ffmpeg.pri)
include(netsdk2.pri)

mingw: QMAKE_LFLAGS += -static

HEADERS += \
    session_test.h
