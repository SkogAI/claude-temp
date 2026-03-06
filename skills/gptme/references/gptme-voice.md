# gptme-voice

## Purpose

Real-time voice interface for gptme agents using the OpenAI Realtime API. Provides a WebSocket server that bridges voice clients (Twilio phone calls or local microphone) to OpenAI's real-time audio model, with a subagent tool that dispatches workspace tasks to gptme running non-interactively. Loads agent personality from gptme.toml project config (ABOUT.md, etc.) for natural voice conversations.

## CLI Commands

| Command | Description |
|---|---|
| `gptme-voice-server` | Start the WebSocket voice server. Options: `--host` (default: 0.0.0.0), `--port` (default: 8080), `--workspace` (explicit path), `--debug` |
| `gptme-voice-client` | Local test client with mic/speaker I/O. Options: `--server` (default: ws://localhost:8080/local) |

## Python API

### Server: `gptme_voice.realtime.server`

| Class/Function | Description |
|---|---|
| `VoiceServer(host, port, openai_api_key, workspace)` | Starlette WebSocket server. Routes: `/` (health), `/twilio` (Twilio Media Streams), `/local` (direct client) |
| `VoiceServer.run()` | Start uvicorn server |
| `main()` | Click CLI entry point |

### OpenAI Client: `gptme_voice.realtime.openai_client`

| Class/Function | Description |
|---|---|
| `SessionConfig` | Dataclass: model (`gpt-4o-realtime-preview-2024-12-17`), voice (`echo`), VAD settings, audio format (PCM 24kHz) |
| `OpenAIRealtimeClient(api_key, session_config, on_audio, on_audio_end, on_transcript, on_function_call)` | WebSocket client for OpenAI Realtime API. Handles bidirectional audio, function calling, session management |
| `OpenAIRealtimeClient.connect()` | Connect and configure session (modalities, tools, VAD, Whisper transcription) |
| `OpenAIRealtimeClient.send_audio(pcm_data)` | Stream audio to API |
| `OpenAIRealtimeClient.inject_message(text)` | Inject subagent result into conversation and trigger response |
| `OpenAIRealtimeClient.disconnect()` | Clean disconnect |
| `_get_openai_api_key()` | Get key from gptme config (`~/.config/gptme/config.toml`) |
| `_detect_agent_repo()` | Walk up from gptme-contrib to find parent with `gptme.toml` |
| `_load_project_instructions(workspace)` | Load personality files (ABOUT.md priority), truncate to 4096 chars |

### Tool Bridge: `gptme_voice.realtime.tool_bridge`

| Class/Function | Description |
|---|---|
| `GptmeToolBridge(gptme_path, timeout, workspace, on_result)` | Dispatches `subagent` function calls to `gptme --non-interactive` in background |
| `GptmeToolBridge.handle_function_call(name, arguments)` | Handle OpenAI function call. Returns immediately with `dispatched` status |
| `ToolResult` | Dataclass: `success`, `output`, `error` |

Subagent tool supports two modes:
- `smart` (default): Uses gptme default model for complex tasks
- `fast`: Uses `openrouter/anthropic/claude-haiku-4.5` for quick lookups

Tasks write results to a temp file (response_file pattern), which is read back and injected into the voice conversation.

### Audio: `gptme_voice.realtime.audio`

| Class | Description |
|---|---|
| `AudioConverter` | Convert between Twilio mu-law 8kHz and OpenAI PCM 24kHz. Methods: `twilio_to_openai()`, `openai_to_twilio()`, `pcm_to_base64()`, `base64_to_pcm()` |

### Local Client: `gptme_voice.realtime.client`

| Class | Description |
|---|---|
| `LocalVoiceTest(server_url)` | PyAudio-based mic/speaker client. PCM 24kHz, 1024 chunk size. Feedback loop prevention: mutes mic during playback + 0.5s cooldown |

## Setup Requirements

- **OpenAI API key**: Loaded from gptme config (`~/.config/gptme/config.toml` or `config.local.toml`), or `OPENAI_API_KEY` env var
- **gptme**: Installed and available in PATH (for subagent tool dispatching)
- **Agent repo**: Optional but recommended — directory with `gptme.toml` containing personality files
- **For local testing**: PyAudio (`pip install pyaudio` or `poetry install -E local`)
- **For Twilio**: Twilio account with Media Streams configured to point at `/twilio` endpoint
- **Python >= 3.10**

## Configuration

| Setting | Source | Description |
|---|---|---|
| OpenAI API key | gptme config or `OPENAI_API_KEY` env | Required for Realtime API |
| Workspace | `--workspace` flag or auto-detected | Agent repo with gptme.toml |
| Personality | `ABOUT.md`, `README.md` from gptme.toml files list | Loaded into session instructions (max 4096 chars) |
| Model | Hardcoded | `gpt-4o-realtime-preview-2024-12-17` |
| Voice | Hardcoded | `echo` |
| VAD | Hardcoded | Server VAD, threshold 0.7, 500ms silence, 300ms prefix padding |

## Dependencies

- `click>=8.0` (CLI)
- `openai>=1.0.0` (API client)
- `websockets>=12.0` (WebSocket client)
- `starlette>=0.37.0` (WebSocket server)
- `uvicorn>=0.30.0` (ASGI server)
- `audioop-lts>=0.2` (Python 3.13+ compatibility)
- Optional: `pyaudio>=0.2.13` (local mic/speaker)
- Build: `hatchling`

## Claude Code Integration

No direct Claude Code backend support. The subagent tool dispatches exclusively to **gptme**. Could be adapted by modifying `GptmeToolBridge._execute()` to spawn `claude -p` instead. The `mode` parameter (fast/smart) maps naturally to Claude model selection.

## Key Source Files

| File | Purpose |
|---|---|
| `src/gptme_voice/__init__.py` | Package metadata |
| `src/gptme_voice/realtime/server.py` | `VoiceServer` — Starlette app with Twilio and local WebSocket endpoints |
| `src/gptme_voice/realtime/openai_client.py` | `OpenAIRealtimeClient` — WebSocket client for OpenAI Realtime API, session config, personality loading, agent repo detection |
| `src/gptme_voice/realtime/tool_bridge.py` | `GptmeToolBridge` — async subagent dispatcher, spawns gptme in background, injects results |
| `src/gptme_voice/realtime/audio.py` | `AudioConverter` — PCM/mu-law conversion between Twilio and OpenAI formats |
| `src/gptme_voice/realtime/client.py` | `LocalVoiceTest` — mic/speaker client with feedback loop prevention |
| `tests/__init__.py` | Test package (empty) |
