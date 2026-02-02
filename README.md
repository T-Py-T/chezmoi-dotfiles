# dotfiles
I'm just getting started with embracing published dotfiles.

## Using chezmoi
I've decided to go all in on chezmoi, even thought I can't
remember that word for anything. 

https://www.chezmoi.io/

Setting up on a new machine


```
$ sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

Then, update dotfiles on a machine from changes in github


```
$ chezmoi update
```

# Thank-yous / inspirations
* [mloberg](https://github.com/mloberg/dotfiles)
* [Dreams of Autonomy](https://www.youtube.com/watch?v=9U8LCjuQzdc)
* [Josean Martinez](https://www.youtube.com/@joseanmartinez)



