#!/bin/bash
set -e

i686-w64-mingw32-g++ \
    -std=c++2b -shared -static \
    -static-libgcc -static-libstdc++ \
    -fpermissive -fcommon -fms-extensions \
    -Wno-invalid-offsetof -Wl,--allow-multiple-definition \
    -DGTASA -DPLUGIN_SGV_10US -DRW \
    -I. -Ishared -Ishared/game \
    -Iplugin_sa -Iplugin_sa/game_sa \
    -Iplugin_sa/game_sa/rw -Isafetyhook \
        examples/RadioDisplay/Main.cpp \
        examples/RadioDisplay/RadioDisplayConfig.cpp \
        examples/RadioDisplay/TrackController.cpp \
        examples/RadioDisplay/TranscriptionController.cpp \
        output/lib/libplugin.a \
    -o "$HOME/games/gtasa/modloader/RadioDisplay/RadioDisplay.asi"

file "$HOME/games/gtasa/modloader/RadioDisplay/RadioDisplay.asi"

bash -ic 'gtasa'