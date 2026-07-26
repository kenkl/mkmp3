# mkmp3
bulk processing/transcoding audio files for iPod Classic 

For the past couple years, I've been playing with reviving my OG iPod Classic, upgrading it with flash storage and fresh battery to pull a 20+ year old technology into the present day. In the past 20 years, lossless files have become A Thing, and as my local libary is increasingly populated with ALAC, (and some FLAC), I was looking for a good way to share these with iPod. Although [Rockbox](https://www.rockbox.org/) works well for blessing iPod with modern music formats, _and_ eliminates the need for iTunes/Apple Music to perform, it can be slightly janky, breaking the UX that the original iPodOS pioneered in navigating local storage. Plus, its power-drain behaviour _seems_ to be much higher than iPodOS, and will pull the battery down past cutoff, forcing a "rescue" operation with Firewire charging to revive the iPod. Not great.

Although iPodOS can parse/play ALAC natively, the low-spec processing power on iPod doesn't handle high-bitrate sources very well. Playing files encoded at 24 bits/44.1kHz makes it stumble, skipping during playback, and often skipping tracks altogether. It gets worse as the bitrate/sample-rate increases. The gold-standard for reliable iPod playback is .mp3, 320kbps with the normal 16bit/44.1kHz encoding.

I have an active Apple Music subscription with my local library shared. As mentioned, it's increasingly populated with ALACs for new/favourite albums, and I'm unwilling to downgrade it just to feed iPod. After all, one of my current projects is to _upgrade_ albums from decades-old low-bitrate .mp3s, not dumb it down.

So, eliminating Rockbox as an option for putting files on iPod, I recently encountered [iOpenPod](https://therealsavi.github.io/iOpenPod/). It works great - populating an iPod with bog-standard .mp3 files with a simple drag-n-drop operation. The other element I was seeking was a simple way to make .mp3 copies of my music _without_ affecting the "canonical" copy already in my iTunes library. [XLD](https://tmkk.undo.jp/xld/index_e.html) does a good job with that (as well as transcoding FLAC to ALAC or whatever format one needs). XLD is a good part of my toolbox, but...

I wanted an easy way to parse through a directory structure (nested folders for Artist/Album), transcode the ALAC files to max-quality .mp3s, and dump those into a flat directory for transfer with iOpenPod.

This project is the answer to that need. It will start with a given top-level directory, transcoding all the ALAC (.m4a) files found there, using ffmpeg, putting the results in a single directory that can be dragged to iOpenPod for transfer.

I've also built logic in to spot .mp3 files in the directory structure and simply copy those over to the flat directory for iOpenPod.

This is developed/tested on MacOS, but should be adaptable to your flavour of Linux, and probably Windows (using WSL?) as well.

Full disclosure - although I know BASH scripting well enough to do this myself, the effort was greatly reduced by employing LLM (Ollama with gemma4:26b for the record) to barf out code snippets that work straightaway. I _have_ fully tested/vetted the code in this script, of course.


