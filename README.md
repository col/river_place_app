# RiverPlaceApp

## Development

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).


# Alexa Voice Scenario's

## Example 1
Me: Alexa, ask River Place to book me a tennis court
Alexa: Ok. When would you like to play?
Me: Tonight
Alexa: What time would you like?
Me: What times are available?
Alexa: There are 3 slots available. 5pm, 7pm and 9pm
Me: Ok, book the 9pm slot please.
Alexa: OK, I've booked court 2 for you tonight at 9pm

## Example 2
Me: Alexa, tell River Place I want to play tennis tomorrow at 9am
Alexa: Both courts are booked at 9am tomorrow. How about 10am?
Me: Sure. That'll do.
Alexa: OK, I've booked court 2 for you tomorrow at 10am

# Utterances

I'm using flutterance here so you need to run this command to generate the utterance.txt file.
``flutterance config/flutterances.txt utterances.txt``

# TODO

- Big code clean up, tests, etc
- Switch to postgres, MySQL is ... not good.
- Add redirect_url to the oauth_clients table
- Fix river_place so that it can manage multiple session tokens
- Add telegram chatbot integration
  - Try to reuse the Alexa config if possible
  - Code once works on alexa and chat?
- 
