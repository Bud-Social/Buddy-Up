// Bench config — the Jitsi webapp runs statically from the bench server and
// talks to the XMPP websocket on the host, so no SSI substitution is needed.
var config = {};

config.hosts = { domain: 'meet.jitsi', muc: 'muc.meet.jitsi' };
config.bosh = 'http://localhost:8080/http-bind';
config.websocket = 'ws://localhost:8080/xmpp-websocket';
config.bridgeChannel = { preferSctp: true };

config.resolution = 720;
config.constraints = {
  video: {
    height: { ideal: 720, max: 720, min: 180 },
    width: { ideal: 1280, max: 1280, min: 320 },
  },
};

// “Start muted when room exceeds N participants” — set absurdly high so ghost
// MUC occupants (zombie XMPP sessions) never force-mute the bench bots.
config.startVideoMuted = 10000;
config.startAudioMuted = 10000;

config.flags = { sourceNameSignaling: true, sendMultipleVideoStreams: true, receiveMultipleVideoStreams: true };

config.enableNoAudioDetection = true;
config.enableTalkWhileMuted = false;
config.disableAGC = false;
config.disableAP = false;
config.disableCallIntegration = false;
config.disableScriptsPreloading = true;

config.toolbarConfig = { timeout: 4000 };
config.mqa = { enabled: true };

config.disableAudioLevels = false;
config.disableDeepLinking = true;
config.prejoinPageEnabled = false;
config.startWithAudioMuted = false;
config.startWithVideoMuted = false;
config.lobby = { enabled: false };

config.toolbarButtons = ['camera', 'chat', 'desktop', 'fullscreen', 'filmstrip', 'hangup', 'microphone', 'settings', 'toggle-camera', 'videoquality'];
