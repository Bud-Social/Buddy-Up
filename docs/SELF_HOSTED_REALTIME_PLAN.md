# BuddyUp self-hosted livestreaming and calling plan

## Goal

Operate livestreaming, one-to-one calls, and small group calls on BuddyUp-owned infrastructure without depending on a hosted realtime vendor. The first milestone keeps the current Flutter/WebRTC clients usable while replacing the vendor-controlled control plane and media deployment with services we operate.

## Target architecture

- **WebRTC media:** self-hosted SFU cluster using LiveKit OSS or an equivalent SFU deployed on BuddyUp infrastructure. The SFU handles simulcast, selective forwarding, adaptive subscriptions, and recording ingress/egress; clients still use WebRTC and do not receive media through Django.
- **Signalling/control plane:** Django service issues short-lived room and participant tokens, applies moderation/entitlement rules, stores room state, and publishes call events over the existing WebSocket layer.
- **ICE connectivity:** coturn on separate public nodes, with UDP first and TCP/TLS 443 fallback. Rotate credentials and never expose permanent TURN secrets to clients.
- **Edge:** regional HTTPS/WSS load balancers, health checks, rate limits, Web Application Firewall rules, and origin-locked media callbacks.
- **Persistence:** PostgreSQL for calls, rooms, participants, moderation actions, and billing events; Redis for presence, fan-out, locks, and short-lived room state; object storage for recordings and thumbnails.
- **Operations:** Prometheus/Grafana metrics, structured logs, trace IDs, media-quality telemetry, alerting, and automated failover tests.

## Delivery phases

### Phase 1 — contracts and security (1–2 weeks)

1. Define room, participant, invite, call-state, recording, report, and moderation APIs shared by web and Flutter.
2. Add server-issued tokens with room, user, role, expiry, and allowed publish/subscribe grants.
3. Add idempotency keys for create/join/leave/end and webhook reconciliation.
4. Define retention, deletion, consent, age gating, abuse escalation, and recording disclosure rules.
5. Add a feature flag so current calls remain available while the new stack is tested.

### Phase 2 — self-hosted media foundation (2–4 weeks)

1. Deploy SFU nodes and coturn with infrastructure-as-code in one primary region and one failover region.
2. Add private service networking, TLS certificates, firewall rules, bandwidth limits, and autoscaling based on participants and outbound bitrate.
3. Build the token and room lifecycle endpoints in Django.
4. Connect media callbacks to PostgreSQL using signed requests and replay protection.
5. Add synthetic publisher/subscriber probes and a canary room before enabling real users.

### Phase 3 — client migration (2–3 weeks)

1. Create a `RealtimeTransport` interface in web and Flutter.
2. Implement self-hosted WebRTC transport behind the feature flag.
3. Preserve chat, reactions, co-host permissions, gifts/tips, call logs, reconnect, background handling, and PiP behavior.
4. Add network-quality UI: reconnecting, weak uplink, muted, camera blocked, and TURN fallback states.
5. Test Android, iOS, modern browsers, low bandwidth, locked screen, permission denial, and process restart.

### Phase 4 — recordings and scale (2–4 weeks)

1. Add recording workers that write encrypted segments to object storage and generate thumbnails asynchronously.
2. Add moderation hooks for mute, remove, block, report, and room shutdown.
3. Load-test room sizes, publish/subscribe bitrates, reconnect storms, and regional failover.
4. Roll out by cohort: staff, creators, 1%, 10%, 50%, then 100%.
5. Remove the hosted-vendor dependency only after reconciliation, quality, billing, and abuse dashboards remain stable for two release cycles.

## Non-negotiable production controls

- Do not route audio/video through Django, Redis, or the browser-facing API.
- Use short-lived signed credentials and server-side room authorization.
- Encrypt signalling and media transport; encrypt recordings at rest and expire them by policy.
- Keep participant and moderation events auditable and idempotent.
- Treat TURN bandwidth as a cost and abuse boundary; enforce quotas and per-room limits.
- Track join success, time-to-first-media, reconnect rate, packet loss, jitter, RTT, bitrate, SFU CPU, TURN egress, recording lag, and moderation latency.

## Definition of done

- A user can start/join/end a livestream or call on web and Flutter using only BuddyUp-operated services.
- Calls recover from temporary network loss and use TURN when direct connectivity fails.
- Room permissions, moderation, reports, call logs, recordings, and billing events match the web/API contract.
- No secrets or permanent room credentials are shipped in either client.
- The service passes load, security, regional failover, data deletion, and abuse-response tests before the hosted path is retired.
