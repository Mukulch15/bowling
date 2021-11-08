# Bowling
This application works as abackend for 10 pin bowling
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
 
How to run the app:
1. First create a game using POST `http://localhost:4000/game`. You will get the following response:
It gives you the initial state and game id which you have to use for subsequent bowls

  ```json
  {

    "frame":1,
    "game_id":"c74ea9fd-0b4b-46b9-88d1-4b38232370c8",
    "pins_left":10,
    "try_no":1
  }
  ```

2. To bowl hit the api POST `http://localhost:4000/game/bowl` with the request body:

  `{
    "game_id": "c74ea9fd-0b4b-46b9-88d1-4b38232370c8",
    "pins_down": 2

  }`
The response will be like:

  `{
    "next_frame": 3,
    "next_try": 1,
    "pins_left": 10
  }`

3. To get scores GET `http://localhost:4000/game/scores?game_id=<GAME_ID>`

  `{
      "res": {
          "frame_scores": {
              "1": 8,
              "2": 15
          },
          "total": 23
      }
  }`

The score api only gives the score when the frame is complete.
Also the application will restore the previous state of an incomplete game if it restarts.
After all the ten frames are over you will get all the frame scores and the total score.
Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
