import QtQuick 2.9

import "." as ZedcoinComponents
import "effects/" as ZedcoinEffects

Rectangle {
    color: ZedcoinComponents.Style.appWindowBorderColor
    height: 1

    ZedcoinEffects.ColorTransition {
        targetObj: parent
        blackColor: ZedcoinComponents.Style._b_appWindowBorderColor
        whiteColor: ZedcoinComponents.Style._w_appWindowBorderColor
    }
}
