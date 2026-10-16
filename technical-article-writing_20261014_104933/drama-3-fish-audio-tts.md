---
layout: article-sky
article_variant: research-review
zoomable_images: true
lang: en
title: 'Drama 3 Explained: Fish Audio''s Directable, Editable TTS'
seo_title: 'Drama 3: Fish Audio''s Directable, Editable TTS'
description: 'Drama 3 explained: direct AI voices, cast multi-speaker scenes and repair words inside a take. Learn its architecture, setup, hardware limits and license.'
keywords: Drama 3, Fish Audio Drama 3, directable text-to-speech, speech editing, audio inpainting
tags:
- voice-agents
- speech-generation
- open-weight-models
categories:
- frontier-research
permalink: /tutorials/drama-3-fish-audio-tts/
thumbnail: /image-gen_20261014_102024/cover/drama-3-cover-1280.webp
og_image: /image-gen_20261014_102024/cover/drama-3-cover-1280.webp
cover_srcset: /image-gen_20261014_102024/cover/drama-3-cover-640.webp 640w, /image-gen_20261014_102024/cover/drama-3-cover-1280.webp 1280w, /image-gen_20261014_102024/cover/drama-3-cover-1536.webp 1536w
cover_alt: A cobalt sound ribbon with one coral segment represents directed speech and a local audio edit.
cover_width: 1280
cover_height: 720
date: '2026-10-14'
last_modified_at: '2026-10-16'
author_name: AgentsPulse Editorial Team
paper_count: 1
research_scope: Directed speech · Scene generation · Local editing
scope_note: An explainer grounded in the technical report, serving code and current license.
dek: Fish Audio’s Drama 3 turns a script into a directed voice performance—with scoped emotion, multi-speaker scenes, contextual revision and local speech repair.
key_takeaways:
- Natural-language directions shape delivery; scoped tags and speaker tokens control different things.
- Multi-turn revision and infilling require audio context. The basic TTS endpoint does not expose every model task.
- Open weights are not unrestricted commercial permission, and the documented local runtime needs NVIDIA hardware.
article_toc:
- id: a-speech-model-built-for-takes-not-a-complete-voice-agent
  label: A speech model built for takes, not a complete voice agent
- id: put-the-direction-where-the-delivery-changes
  label: Put the direction where the delivery changes
- id: cast-a-scene-without-treating-reference-order-as-identity
  label: Cast a scene without treating reference order as identity
- id: a-directors-note-and-a-word-repair-are-different-operations
  label: A director's note and a word repair are different operations
- id: the-architecture-preserves-acoustic-context-not-just-text-intent
  label: The architecture preserves acoustic context, not just text intent
- id: try-a-directed-line-before-building-an-editing-product
  label: Try a directed line before building an editing product
- id: deployment-decisions-need-more-than-the-launch-headline
  label: Deployment decisions need more than the launch headline
- id: drama-3-faq
  label: Drama 3 FAQ
- id: references
  label: References
faq_schema:
- question: Can Drama 3 run on a Mac?
  answer: Not through the current documented Fish Speech inference path. Drama 3 requires NVIDIA GPUs and does not support Apple MPS or CPU inference there. A Mac can still call a hosted service as client, which is different from running weights locally.
- question: Is Drama 3 open source?
  answer: Code and weights are publicly released, but under Fish Audio Community License rather than permissive Apache/MIT terms. Revenue limits, hosted-service restrictions, and other obligations apply. For deployment decisions, “open-weight” is the more accurate shorthand.
- question: Does Drama 3 support voice cloning and multiple speakers?
  answer: Yes. References can establish voice identity, and explicit speaker IDs map dialogue to intended speakers. The report also describes scene generation from character descriptions, which is distinct from cloning an identifiable person; that requires proper rights.
- question: Can I edit one word through the standard TTS endpoint?
  answer: The model supports infilling, but the standard public TTS schema does not document a dedicated edit window or conversation-history field. Confirm an editing-capable interface and contract before building around it; changing only text regenerates output rather than explicitly repairing an existing waveform.
related_research:
- url: /tutorials/real-time-voice-agents-distributed-systems/
  title: Real-Time Voice Agents Are Distributed Systems
  description: Where transport, turn handling and state shape the listening experience.
- url: /tutorials/model-gateway-enterprise-ai-control-plane/
  title: The Model Gateway as a Control Plane
  description: Routing, policy and budgets around production model calls.
---

Drama 3 is Fish Audio's speech-generation model for directing and revising a voice performance, not just reading a transcript aloud. You can describe the delivery you want in plain language, scope a whisper to a few words, cast several voices in one scene, and replace a small part of an existing take. Released on October 13, 2026, it ships open weights for a 35-billion-parameter mixture-of-experts backbone that activates about 3 billion parameters per token. In other words, it is a large speech model with sparse per-token compute, not a lightweight 3B model.

The practical shift is a new production loop: **write, direct, listen, then revise the performance or repair the moment that failed**. For game dialogue, audiobooks, and spoken character responses, that loop can be more useful than regenerating whole clips. Keep in mind that the model, Fish Audio's hosted editor, and the repository's TTS server are different surfaces: a capability described in the technical report is not automatically a field that `/v1/tts` accepts ([Fish Audio README](https://github.com/fishaudio/fish-speech), [technical report, §§1–3](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

## A speech model built for takes, not a complete voice agent

Drama 3 generates speech from text plus conditioning context: a reference voice, written directions, or audio it generated earlier. It handles standard TTS and voice cloning, but what sets it apart are four tasks new in this release: multi-turn director revision, scene dubbing, speech infilling, and streaming text input.

It is not a speech recognizer, a tool-using assistant, or a full-duplex conversation runtime. A voice agent still needs its own reasoning, turn management, safety checks, and playback infrastructure. Drama 3 can render the spoken performance; it does not decide whether the reply is correct. Our [real-time voice-agent systems explainer](/tutorials/real-time-voice-agents-distributed-systems/) covers those transport and state concerns.

Natural-language direction and multi-speaker generation are not new either—Fish Audio's S2 family already offered both. The bigger change comes after the first take: contextual revision and local editing, backed by a new architecture and new task training ([README, comparison with S2-Pro](https://github.com/fishaudio/fish-speech#what-changed-compared-with-s2-pro)).

| Need | Drama 3's relevant capability | Check before adopting |
|---|---|---|
| A line delivered with a specific intent | Natural-language directions and scoped controls | Whether the intended emotion is audible without losing words |
| Several characters in a scene | Speaker-tagged references or character descriptions | Voice identity, line boundaries and consistency across turns |
| A better version of an existing take | A relative note with earlier audio in context | Whether the serving interface retains the take, not just its text |
| One incorrect word in a usable recording | Infilling with audio before and after the edit | Alignment, edit boundaries and audible joins |
| Speech from incrementally arriving text | A streaming-input task with look-ahead | The application buffering and serving path, not only model support |

<img src="/archify_20261016_165854/drama-3-architecture.webp" width="736" height="1810" loading="lazy" decoding="async" alt="Simplified Drama 3 TTS path from a directing client through the hybrid backbone, codebook-MTP decoder and DAC codec to playback." data-zoomable title="Click to enlarge" style="width: 100%; max-width: 440px;" />

*Figure 1. A simplified TTS serving path. The serving layer encodes voice references into tokens; fine codes 2–9 also enter the codebook decoder directly, a side path omitted here. Playback returns the performance to the listener.*

## Put the direction where the delivery changes

Drama 3 reads directions at several scopes. They are written in plain language, but scope still matters: if the script never marks where a change begins and ends, the model cannot reliably tell *which words* should change.

### Point events and line-level intent

A point tag inserts a vocal event or a pause at its position:

```text
Alright, [sighs] let's try again.
```

A style prefix sets the delivery of the whole line:

```text
[trying to reassure someone, but still frightened] We have time.
```

These are illustrative prompts, not guaranteed outputs. Because the report treats direction text as ordinary language, you are not limited to a fixed list of emotions. Describe audible behavior—pace, intensity, hesitation, or who is being addressed. Placement carries meaning too: a point tag acts where it sits, while a style prefix covers the whole line ([technical report, §3.2 and Appendix C](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

### Scoped tags delimit an effect

Paired tags apply a direction only to the words they enclose:

```text
I'm fine. Really. <whisper>Go on without me.</whisper>
```

That is different from putting a whisper instruction at the start of the whole line. The report lists scoped forms such as `<whisper>`, `<slow>`, and `<emphasis>`, and in Fish Audio's hosted editor users can select words and apply scoped tags to them. This is Fish Audio's own syntax; do not assume SSML compatibility ([Drama 3 product page](https://fish.audio/drama-3/), [report, Appendix C](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

Structural tokens do a different job. `<|speaker:0|>` sets speaker identity, and `<|audio_separator|>` separates lines in line-aligned formats. Each is a single vocabulary token that gives the request its structure, whereas a direction such as `[nervous]` is ordinary text the model interprets. Keep the two kinds apart.

<img src="/archify_20261016_165854/drama-3-controls.webp" width="736" height="1560" loading="lazy" decoding="async" alt="Four independent Drama 3 controls: line-level style, a point event, scoped words and speaker identity." data-zoomable title="Click to enlarge" style="width: 100%; max-width: 480px;" />

*Figure 2. Four independent control categories, not four sequential stages. A scoped effect changes only enclosed words; a speaker token chooses identity rather than emotion.*

Start with a single-variable test: keep the sentence and the voice fixed, compare a neutral read with a directed one, then scope just one phrase. Check both the audio and the transcript. Extra expressiveness does not help if dates, names, or instructions become harder to understand.

## Cast a scene without treating reference order as identity

The report describes two related workflows. In **reference-based dialogue**, one or more clips establish each voice. In **scene dubbing from text**, character descriptions define the cast and the whole script is supplied up front. The model is trained to output one audio segment per line, joined by separators, so each line can be performed with awareness of the lines that follow.

In reference-based generation, speaker tokens bind lines to voices:

```text
<|speaker:0|> [calm, asking a direct question] Were you there?
<|speaker:1|> [defensive] I was home. <emphasis>Asleep.</emphasis>
```

Documented speaker IDs run from 0 to 15. Several references can share one speaker token, so two clips of voice A still make one character. Reference block numbers and speaker IDs are not interchangeable, and the current client exposes `--reference_speaker` to make the mapping explicit ([inference documentation](https://speech.fish.audio/inference/), [technical report, Appendix B, Figure 11](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

Long-form work also depends on how the serving code manages context. The report shows whole-scene and line-separated tasks, but by default the repository's Drama 3 generation splits long text into chunks of roughly 300 UTF-8 bytes and feeds the first and the latest generated chunks back into later prompts. `single_chunk` turns splitting off, still within generation and context limits. So “generate a scene” does not mean “process an arbitrarily long book in one unbounded request” ([current generation implementation](https://github.com/fishaudio/fish-speech/blob/1ff3c3ed2f80d3106a83909dd25b83129c3d816f/fish_speech/models/text2semantic/inference.py#L879)).

### Keep one character's voice across languages

Drama 3 can perform a character's lines in different languages while keeping the same voice. The report states language coverage inherited from S2 is **about 80 languages and dialects**, while its multilingual cloning benchmark evaluates **24 languages**. Those are not interchangeable claims: coverage scope and evaluated set are different, so this should not be presented as equal quality in every supported language ([technical report, §§1, 3.1, 5.3.2](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

For control syntax, the optional `[language: xx]` hint names the request's main language and is not spoken; each line is still rendered in the language of its own text, so the hint is not a translation tool. In practice, keep the same `<|speaker:0|>` token for the same character across multilingual lines, then verify names, numbers, and mixed-language phrases in listening review. Line- and span-level directions control delivery; they do not guarantee perfect timbre consistency or establish a phoneme-level editing interface ([technical report, Appendix C](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

## A director's note and a word repair are different operations

A relative direction revises the delivery of an earlier take:

```text
[softer and warmer versus previous] The results just came in. We didn't make it.
```

For the note to be truly relative, the audio of the previous take has to be in context. Re-sending the same sentence with “versus previous” to a stateless endpoint tells the model nothing about what listeners actually heard. Fish Audio's multi-turn format places earlier generated takes before the new instruction ([report, Appendix B, Figure 12](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

**Infilling** (audio inpainting) is narrower. Suppose a usable line says “The demo is Wednesday, not Friday,” but the day should be Thursday. The goal is to replace that one word while preserving the surrounding performance, not to redirect the whole line.

In the report's editing flow, the source audio is aligned with its transcript and the changed span is located. The model then receives the corrected full text plus the source audio tokens before and after that span, and generates only the missing middle. Both boundaries matter: the replacement should rejoin the existing rhythm and intonation instead of sounding like an isolated retake. A deletion leaves no new text to generate, so in evaluation its window also takes in an adjacent unchanged word.

<img src="/archify_20261016_165854/drama-3-editing.webp" width="736" height="1810" loading="lazy" decoding="async" alt="Local speech repair: align a take, choose a word, condition on both sides, generate replacement codes and reconstruct audio." data-zoomable title="Click to enlarge" style="width: 100%; max-width: 440px;" />

*Figure 3. Repairing Wednesday to Thursday conditions on the original audio on both sides. Whole-sequence decoding and splicing with crossfades are different reconstruction protocols, not interchangeable benchmark settings.*

“Keep everything around it” does not necessarily mean the waveform stays byte-identical. In one evaluation, the entire token sequence is decoded again, unedited spans included. In the Cartesia Sonic-3 comparison, the replacement audio is pasted into the original recording with loudness matching and a 20 ms crossfade. Because the protocols differ, their scores should not be pooled ([report, §5.5](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

The public `ServeTTSRequest` schema covers text, references, sampling, and streaming, but it has no explicit infill window and no field for prior takes. The report documents the task formats; an ordinary TTS request is not a complete API contract for every one of them. Before committing to editing features, confirm a hosted or self-hosted interface that actually supports them rather than inventing an `inpaint=true` flag ([request schema](https://github.com/fishaudio/fish-speech/blob/1ff3c3ed2f80d3106a83909dd25b83129c3d816f/fish_speech/utils/schema.py)).

## The architecture preserves acoustic context, not just text intent

Drama 3 reuses S2's audio tokenizer, which is built on the Descript Audio Codec. It represents 44.1 kHz audio at roughly 21.5 frames per second, with ten codebooks per frame. Codebook 0 carries semantic information, and codebooks 1–9 add residual acoustic detail. They are learned discrete codes, not ten separate audio tracks.

The backbone is initialized from the language component of Qwen3.5-35B-A3B. Its hybrid attention stacks blocks of three Gated DeltaNet layers and one full-attention layer. The DeltaNet layers, a form of linear attention, carry history in a constant-size state; the full-attention layers keep exact retrieval over the whole context, such as a reference clip's timbre or a line far back in the script. Sparse experts cut the compute per token, but the inactive weights still have to be stored.

For generated and reference audio, only codes 0 and 1 are fused into the backbone input. Codes 2–9 bypass the backbone and go straight to the codebook-MTP decoder as side input. The decoder has four shared layers followed by nine codebook-specific layers, and every layer attends causally along time. That lets it draw on fine acoustic detail from references and earlier frames instead of relying only on a compressed backbone summary ([report, §2](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

Here, **multi-token prediction runs along the codebook axis** within a frame. It does not mean several future frames are generated at once, and each code prediction still depends on the codes chosen before it.

The training objective changed too. A single learned human-preference reward replaces S2's mix of transcription, quality, and speaker-similarity rewards. The reasoning is practical: a requested whisper or laugh can lower transcription and similarity scores even when it is exactly the intended performance. Fidelity still matters, since the preference model sees the script and the references, but the reward is meant to judge delivery against the direction rather than against a neutral reading alone ([report, §3.3](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

## Try a directed line before building an editing product

The quickest way to evaluate Drama 3 is Fish Audio's [Drama 3 page](https://fish.audio/drama-3/) and its Text to Speech editor. Start with a voice you have the rights to use, a short sentence, and one clearly audible direction. Listen for whether the effect starts where you intended and whether names and numbers stay correct. Auto Tag can suggest directions, but a suggestion is not a validation.

Self-hosting needs much heavier hardware. The current Fish Speech docs specify Linux or WSL, an NVIDIA GPU, and at least 48 GB of GPU memory for Drama 3 in FP8. The documented path does not support CPU inference, Apple MPS, AMD ROCm, or `--compile`, so don't carry over S2-Pro hardware assumptions ([installation requirements](https://speech.fish.audio/install/)).

After installing Fish Speech and downloading `fishaudio/drama-3` into `checkpoints/drama-3`, the documented CLI produces decoded audio in a single command:

```bash
python fish_speech/models/text2semantic/inference.py \
  --checkpoint-path checkpoints/drama-3 \
  --text "[warm and relaxed] It's been a while." \
  --prompt-audio "reference.wav" \
  --prompt-text "The exact transcript of reference.wav" \
  --output "output.wav" \
  --device cuda:0
```

Replace both reference placeholders with a consented recording and its exact transcript. The command comes from the documentation; we did not run it locally. The weights also need `codec.pth`: if it is missing from the Drama 3 directory, the install docs fall back to the S2-Pro codec, so download S2-Pro as well.

To serve TTS locally, the documented entry points are:

```bash
python tools/api_server.py \
  --listen 127.0.0.1:8080 \
  --llama-checkpoint-path checkpoints/drama-3 \
  --device cuda:0

python tools/api_client.py \
  --url http://127.0.0.1:8080/v1/tts \
  --text "[calm and reassuring] We have time." \
  --output demo \
  --no-play
```

This example binds the server to loopback only. The client sends the msgpack body that `/v1/tts` expects, so don't assume a generic JSON TTS payload will work. The model is fixed by the checkpoint loaded at server startup, not chosen per request. For efficiency, the repository recommends SGLang-Omni, a separate serving path worth evaluating on its own; it is not a measured speedup of this example ([inference documentation](https://speech.fish.audio/inference/), [README](https://github.com/fishaudio/fish-speech)).

## Deployment decisions need more than the launch headline

### Decode speed is not first-audio latency

Fish Audio reports that Drama 3 decodes one stream at 271 frames/s on a single H200, versus 177 for S2 under the same setup. That is a vendor-reported **concurrency-1 decode rate**: how fast frames arrive once decoding is under way, against a real-time playback need of about 21.5 frames per second. It excludes the prefill that reads text and reference audio, as well as weight loading, transport, and playback, and it is not a latency guarantee for other GPUs or for the repository's default server ([report, §4.1](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

For interactive agents, measure time to first audio, stalls, interruption behavior, and concurrency using your real text and reference lengths. A [model gateway](/tutorials/model-gateway-enterprise-ai-control-plane/) can centralize routing and budgets, but it cannot turn a decode benchmark into a responsiveness guarantee.

### Revision and editing are not universal wins

On Step-Audio-Edit, the report's results improve over three revision rounds: emotion accuracy rises from 55.5% to 58.2%, and style accuracy from 76.5% to 81.8%. These are vendor-run benchmark results scored by a model judge, not by human listeners. The quoted Step-Audio-EditX baseline still reaches higher final emotion accuracy, at 69.3%, although Drama 3 leads on style in the same table.

Likewise, Drama 3's English substitution WER of 2.08% on the Ming-Freeform basic split is not the best in its table: the quoted CosyEdit2 result is 1.43%. The report also regenerates outputs that fail simple signal checks, so final scores are not unconditional first-take success rates ([report, §5.1, Tables 7 and 9](https://github.com/fishaudio/fish-speech/blob/main/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf)).

The defensible takeaway: one model now covers several useful production tasks, but it is not the best at everything on every benchmark.

### Open weights have a specific license

The Fish Audio Community License v1.0 allows research and non-commercial use, plus limited commercial use while the combined annual gross revenue of you and your affiliates is below US$500,000. That figure is total revenue from all sources over the trailing 12 months, not just revenue from generated speech.

Offering a Hosted Service, meaning one where third parties generate speech from text or voice samples they supply, requires a separate written license regardless of revenue. Section III(c) excludes three cases from that definition: speech for content you create or your own product generates (such as an assistant's spoken replies), production work in which you direct each generation and deliver only finished audio to a client, and free, non-commercial research or demonstration services that are neither monetized nor offered or promoted as a production service or API. If you deploy the materials for a particular third party's own use, that party must also be under the revenue threshold. “Under $500,000” is not blanket permission to launch a TTS platform.

The terms also require a “Built with Fish Audio” attribution when you distribute or offer the materials or a product that uses them, require consent or another legal right before imitating an identifiable person's voice, and prohibit intentionally removing watermarks or provenance signals. They also bar using the materials or their outputs to train other foundational generative models or speech-generation models. Read the actual [license](https://github.com/fishaudio/fish-speech/blob/1ff3c3ed2f80d3106a83909dd25b83129c3d816f/LICENSE) rather than treating “open weights” as Apache/MIT-equivalent permission. This summary is deployment-oriented, not legal advice.

## Drama 3 FAQ

### Can Drama 3 run on a Mac?

Not through the current documented Fish Speech inference path. Drama 3 requires NVIDIA GPUs and does not support Apple MPS or CPU inference there. A Mac can still call a hosted service as client, which is different from running weights locally.

### Is Drama 3 open source?

Code and weights are publicly released, but under Fish Audio Community License rather than permissive Apache/MIT terms. Revenue limits, hosted-service restrictions, and other obligations apply. For deployment decisions, “open-weight” is the more accurate shorthand.

### Does Drama 3 support voice cloning and multiple speakers?

Yes. References can establish voice identity, and explicit speaker IDs map dialogue to intended speakers. The report also describes scene generation from character descriptions, which is distinct from cloning an identifiable person; that requires proper rights.

### Can I edit one word through the standard TTS endpoint?

The model supports infilling, but the standard public TTS schema does not document a dedicated edit window or conversation-history field. Confirm an editing-capable interface and contract before building around it; changing only `text` regenerates output rather than explicitly repairing an existing waveform.

## References

- Fish Audio Team. [Fish Audio Drama 3 Technical Report](https://github.com/fishaudio/fish-speech/blob/1ff3c3ed2f80d3106a83909dd25b83129c3d816f/docs/assets/Fish_Audio_Drama_3_Technical_Report.pdf). 2026, architecture, task formats and evaluation.
- Fish Audio. [Fish Speech repository and README](https://github.com/fishaudio/fish-speech/tree/1ff3c3ed2f80d3106a83909dd25b83129c3d816f). Source revision checked October 14, 2026.
- Fish Audio. [Installation](https://speech.fish.audio/install/) and [inference guide](https://speech.fish.audio/inference/). Current repository documentation checked October 14, 2026.
- Fish Audio. [Drama 3 product introduction](https://fish.audio/drama-3/) and [launch article](https://fish.audio/blog/fish-audio-drama-3/). October 13, 2026 launch.
- Fish Audio. [Community License v1.0](https://github.com/fishaudio/fish-speech/blob/1ff3c3ed2f80d3106a83909dd25b83129c3d816f/LICENSE). October 13, 2026.