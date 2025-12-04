# How to Add Voice Files to Your App

## Step 1: Prepare Your Voice Files

You need to add voice sample MP3 files to the `assets/voices/` folder. Each file should be named exactly as shown below:

### Required Files:
1. `andrea.mp3` - Andrea voice sample
2. `burt.mp3` - Burt voice sample
3. `drew.mp3` - Drew voice sample
4. `joseph.mp3` - Joseph voice sample
5. `marissa.mp3` - Marissa voice sample
6. `mark.mp3` - Mark voice sample
7. `matilda.mp3` - Matilda voice sample
8. `mrb.mp3` - MRB voice sample
9. `myra.mp3` - Myra voice sample
10. `paul.mp3` - Paul voice sample
11. `paula.mp3` - Paula voice sample
12. `phillip.mp3` - Phillip voice sample
13. `ryan.mp3` - Ryan voice sample
14. `sarah.mp3` - Sarah voice sample
15. `steve.mp3` - Steve voice sample

## Step 2: File Location

Place all MP3 files in:
```
c:\Users\Tanjim\StudioProjects\gastcallde\assets\voices\
```

## Step 3: File Requirements

- **Format**: MP3 (recommended), WAV, or M4A
- **Duration**: 3-5 seconds (short greeting)
- **File Size**: Under 500KB each
- **Sample Rate**: 44.1kHz or 48kHz
- **Bit Rate**: 128kbps or higher

## Step 4: Sample Content

Each voice file should contain a short greeting like:
- "Hello, I'm Andrea, your AI voice assistant."
- "Hi there! This is the Burt voice."
- "Welcome to [Restaurant Name]. I'm Matilda."

## Step 5: After Adding Files

1. Save all MP3 files to `assets/voices/` folder
2. Run: `flutter pub get` (optional, already configured)
3. Run: `flutter run` to rebuild the app
4. Test by clicking the play button next to each voice in Settings

## How It Works

- Click the **Play** button (▶️) to hear a voice sample
- The button changes to **Stop** (⏹️) while playing
- If a voice file is missing, you'll see an error message
- Voice selection and speed settings are saved to the backend API

## Troubleshooting

**Error: "Voice sample not available"**
- Make sure the MP3 file exists in `assets/voices/`
- Check that the filename matches exactly (lowercase, .mp3 extension)
- Verify the file is not corrupted

**Audio doesn't play:**
- Ensure your device volume is turned up
- Check file format is MP3, WAV, or M4A
- Try with a different voice file

## Where to Get Voice Samples

You can:
1. Record your own voice samples
2. Use text-to-speech tools to generate samples
3. Use AI voice generators (ElevenLabs, etc.)
4. Download sample voices from voice provider websites

## Implementation Details

The app uses:
- `audioplayers` package for playback
- `AssetSource` to play from assets folder
- Automatic play/stop toggle with visual feedback
- Error handling for missing files
