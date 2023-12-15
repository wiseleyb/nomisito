# Nomisito code example

Nomisito: play on Nom nom + necisito (Spanish: need) 

This is a screening code test for a company.

## What's being delivered

A very basic UI can be used to hit a modularized backend supporting two APIs
with an interface design that should be easy to extend to future APIs.

* **Live site** (Heroku):
  [https://nomisito-46f260c218eb.herokuapp.com/](https://nomisito-46f260c218eb.herokuapp.com/)
* **Source code**
  [https://github.com/wiseleyb/nomisito](https://github.com/wiseleyb/nomisito)
* **Code documentation:**
  [https://nomisito-46f260c218eb.herokuapp.com/doc/index.html](https://nomisito-46f260c218eb.herokuapp.com/doc/index.html)
(Google-Chrome might warn this is dangerous - it's not - it's just standard
Yardoc - didn't spend anytime fixing that) 
* **API keys** (will be emailed)

Assumptions/Hacks/Shortcuts

* This assumes that it only needs to search one API at a time (so no combined
  search results)
* For the second API (TheMealDb) I didn't implement paging - just to save time,
  and keep things simple. This can be wonky given occasional missing ingredients.
* Most APIs I looked at (that even offered) ingredient filters were
  inconsistent with AND vs OR for filtering. Given that I do this post API
search. I originally had this on the per API level ... but that makes the UI
inconsistent. You could do this either way though - this was simpler.
* I used [Edamam](https://www.edamam.com/) for dietary-restrictions. That
  service is significantly rate-limited (35/min) on the free account. It returns a ton
of information - but I'm just using the dietary restrictions for this task (to
keep it simple).
* I store the return values of Edamam in a jsonb field. This is a hack but
  allows debugging/development/testing without having to constantly hit their
API. IRL you'd probably clean this up (parse out what you need and store only
that).
* API calls are all in one place but I'm not doing things like handling
  timeouts, retries, etc - which would also be standard in a production app.
* Specs are minimal and mostly there to show that I know how to write specs
* Most of rubocop is supported (formatting)
* You might notice the 20MB seeds.rb file... this was to make getting this
  running on your box as simple and foolproof as possible. I wouldn't do this
in a real project. You can still populate the DB via API calls, but it's slow
due to rate limits. 
* The UI is extremely basic, like Craigslist level :) I figured this was mostly
  a backend exercise.
* Docker files are included to run this in dev (in case your dev box doesn't
  have Postgres or something)

## Challenge (from the company requesting this)

### Goal

Your goal is to create an application that will let you search and filter taco
recipes. Leverage an API to find the taco recipes. Use a free API to start, but
be sure to build the application in a way that makes swapping out different
APIs as easy as possible so that its possible to extend this application in the
future.

Create a persisted data store for ingredients so that you will be able to
display recipes you fetch according to their dietary friendliness. You should
be able to filter the taco recipes by both ingredients and dietary
restrictions.

Finally, imagine you want to turn this into a software product and sell it to
the public. What would your recommendations be for an easily scalable SaaS
product and its accompanying infrastructure? We're not expecting an essay or
full proposal, just some thoughtful recommendations about how you would build
and deploy this as a SaaS product. Feel free to document your response in a
README.
  
### Assumptions

* Search results can update on form submit. Searching does not need to occur in
  real-time, as the user types.
* Use your best judgment with regard to the dietary restrictions. Identifying
  these can be complicated. Document your assumptions.

### Acceptance Criteria

* User can search by recipe name and see matching results.
* User can filter recipes by ingredients and see recipes that contain those
  ingredients.
* User can filter recipes by dietary restrictions and see recipes that are safe
  for the selected restriction. The taco recipe data is fetched dynamically
from an API.
* Ingredient data is persisted.

### Data

Here are some suggested free APIs you could use for your application. However,
if there is an API you would rather use, feel free. In your README, please
explain why you chose the API you're using.

* [https://github.com/madeintandem/guac-is-extra](https://github.com/madeintandem/guac-is-extra)
* [https://www.themealdb.com/api.php](https://www.themealdb.com/api.php)

## SaaS thoughts

```
Finally, imagine you want to turn this into a software product and sell it to
the public. What would your recommendations be for an easily scalable SaaS
product and its accompanying infrastructure? We're not expecting an essay or
full proposal, just some thoughtful recommendations about how you would build
and deploy this as a SaaS product. Feel free to document your response in a
README.
```

There's one major decision which effects everything else: is your product
searching all APIs or per API. Are you seeking to combine everything into a
unified look/feel or allow users to get the most out of each API? For example
GuacIsExtra doesn't have images, while TheMealDb does... that's a pretty
different UI experience. 

In either case, I don't think this works as a real-time API call solution. I
would approach this by caching data and running download load jobs behind the
scenes. This makes the most sense to me as a full-text search problem give the
nearly infinite number of ingredients (and variations). 

Other challenges include the dietary restrictions requirement. This is super
complex. Unless you have a huge budget you're realistically relying on
something like [Edamam](https://www.edamam.com/) or
[Spoontacular](https://spoonacular.com/food-api) to figure out ingredient
information like dietary restrictions (Vegan, etc), or calories, recipe sugar
content, etc. Screwing something up like peanut allergies also has significant
legal liability (example: can you use peanut oil if you have peanut allergies?)

My general approach would be:

* Download all data available for a given API.
* Use a consistent service to categorize what is needed. Sites like
  Spoontacular do a pretty good job of taking a text recipes and figuring out
ingredients, steps, etc. Sites like Edamam do a good job of giving you
calories, dietary restrictions, etc for ingredients. Doing this manually probably
isn't realistic given something like 200,000+ ingredients. Using this approach would
allow you do use very simple data as well, like my terrible 
[recipe site](https://github.com/wiseleyb/recipe-files) and have that work just
as well as API Recipe sites.
* Leverage something like ElasticSearch to support full-text search. In a pinch
  you could do this in Postgres - but it's slow and not great. A Large Language
Model (ChatGPT/Gemini-type products) would be an interesting option for this as
well.
* Figure out an update schedule to keep data fresh (run as cron jobs on
  multiple servers async, periodically)
* Use some basic login/api-key type auth to determine what customers have
  access to, how many searches, they're allowed, filter-to-some-specification
(like maybe your Saas offers Paleo recipes only options or maybe
cooking-for-two), etc. 
* Depending on goals, costs, and traffic expectations you could do this as a
  monolithic app (mutli-tenant) or give 
  each new client their own servers (single-tenant). Both have 
  advantages/disadvantages.

## Setup

### Setup without docker

This assumes you have Postgres installed and running... this can be a hassle. It
might be easier to setup via Docker (see below).

```
git co https://github.com/wiseleyb/nomisito/
cd nomisito
bundle install
rake db:create db:migrate db:seed

# You can also populate the data from the actual APIs... this is pretty
# slow do to rate limiting.
# rake setup:reset

open http://localhost:3000/
```

### Setup with Docker

Get [Docker Desktop](https://www.docker.com/products/docker-desktop/)

[Add aliases](https://gist.github.com/wiseleyb/e12fd7686274457e4fb69b491ee45329)

```
dcbuild
dcrake db:create db:migrate db:seed
dcrake db:create RAILS_ENV=test
dcup
```
[open http://0.0.0.0:3000/](http://0.0.0.0:3000/)

* Run specs `dcrspec`
* Run rubocop `dccop`
* Run rails console `dccon`
* Run postgres console `dcpsql`

## Heroku

This is up on Heroku at  
[https://nomisito-46f260c218eb.herokuapp.com/](https://nomisito-46f260c218eb.herokuapp.com/)

Some hacks if deploying to new Heroku instance:

```
bundle lock --add-platform x86_64-linux
git push heroku main
add env keys to heroku
heroku logs --tails
heroku run rake db:create db:migrate db:seed
```

## Yard Documentation

Yard docs are up on Heroku right now
[https://nomisito-46f260c218eb.herokuapp.com/doc/index.html](https://nomisito-46f260c218eb.herokuapp.com/doc/index.html)

Some yard notes:

```
Put yard doc in public to easily view on live site
echo --output-dir public/doc >> .yardopts

Cheat sheets:
* https://gist.github.com/chetan/1827484
* https://kapeli.com/cheat_sheets/Yard.docset/Contents/Resources/Documents/index

Build yard docs: yard
View docs: yard server then open https://localhost:8808
```

