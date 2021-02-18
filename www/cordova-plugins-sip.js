module.exports =
{
    finish: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "finish",
            []
        );
    },
    login: function (username, password, domain, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "login",
            [username, password, domain]
        );
    },
    setPushNotification: function (appId, regId, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "setPushNotification",
            [appId, regId]
        );
    },
    ensureRegistered: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "ensureRegistered",
            []
        );
    },
    logout: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "logout",
            []
        );
    },
    accept: function (value, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "acceptCall",
            [value]
        );
    },
    listenCall: function (successCallback, errorCallback) {
        cordova.exec(
                successCallback,
                errorCallback,
                "Linphone",
                "listenCall",
                []
            );
    },
    setStunServer: function (stunServer, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "setStunServer",
            [stunServer]
        );
    },
    disableStunServer: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "disableStunServer",
            []
        );
    },
    call: function (address, displayName, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "call",
            [address, displayName]
        );
    },
    videocall: function (address, displayName, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "videocall",
            [address, displayName]
        );
    },
    hangup: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "hangup",
            []
        );
    },
    toggleVideo: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "toggleVideo",
            []
        );
    },
    toggleSpeaker: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "toggleSpeaker",
            []
        );
    },
    toggleMute: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "toggleMute",
            []
        );
    },
    sendDtmf: function (number, successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "sendDtmf",
            [number]
        );
    },
    sendLogcat: function (successCallback, errorCallback) {
        cordova.exec(
            successCallback,
            errorCallback,
            "Linphone",
            "sendLogcat",
            []
        );
    },
};