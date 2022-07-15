# kitten pairs
> Simple matching game with kittens

[![](https://media0.giphy.com/media/3zrjGFggccFag/giphy.gif?cid=ecf05e47jk69wmzsh6zrcgcqntnyv31jbp7ot11f68dn98ji&rid=giphy.gif&ct=g)](https://giphy.com/gifs/3zrjGFggccFag)

## Why?

It started as a fun project. I wanted to play around with Elixir/Phoenix and was looking for something cool. Implementing yet another to-do list was kinda boring. Also, who doesn't like simple online games and cat content? 🤭

➡️ Have fun: https://kitten-pairs.fly.dev/

## Development

Before setting up the project locally, make sure you have [Podman](https://podman.io/) and Elixir/Erlang on your computer.

```sh
git clone git@github.com:henrikfricke/kitten_pairs
cd kitten_pairs

# Start local postgres database
make postgres

# Install dependencies and run database migrations
make install

# Start server
make start
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser. See [Makefile](./Makefile) for more commands.
