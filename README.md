# cobol-worker

## Play

The possible picks are `rock`, `scissors` and `paper`.

```sh
curl -d "pick=rock" https://cobol.demos.cloudflare.com | jq .
```

## Deploy

Make sure to change the `wrangler.toml` with your zone's information.

```sh
npm run deploy
```
