# Jason Hee's private Dotfiles

My private dotfiles that contains sensitive credentials or local settings that I do not want to share with the world.

## Prequisties
The extra files are encrypted using [git-crypt](https://github.com/AGWA/git-crypt). To decrypt the files, may need to do the following:

- Install GPG command line tools `brew install gnupg`
- [Generate a GPG key and add it to my Github Account](https://help.github.com/articles/generating-a-new-gpg-key/)

## Usage
```sh
$ git clone git@github.com:jasonheecs/dotfiles-private.git ~/.dotfiles/private
$ cd ~/.dotfiles/private && git-crypt unlock
```

## Notes
To check which files have been encrypted by git-crypt, use the following command:
```sh
git-crypt status
```
