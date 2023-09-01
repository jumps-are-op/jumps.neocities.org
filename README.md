# [My webpage](https://jumps.neocities.org) *finally*

I don't use bloated software like Jekyll, Minimal Mistakes, and HUGO to
make this website.

I wrote my own site generator `gensite.sh`
and my own RSS feed generator `makerss`.

Everything here is a POSIX shell script,
one exception is `jmu`, which is written in sed.
Yes, sed is a valid scripting language.

To add a new blog use `newblog`.

`gensite.sh` uses `footer` and `header` to generate headers and footers.

`footer` is also used to generate blog list in `/blog/index.html`.

`extractor` is used to extract RSS content from blogs.

`gensite.sh` and `makerss` needs to be configured throw environment
variables, so `gensite` is a wrapper to setup environment.

Everything else is done manually, YES **EVERYTHING**!
