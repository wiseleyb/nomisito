# Nomisito

Nomisito: play on Nom nom + necisito (Spanish: need) 

This is a screening code test for a company.

## Challenge

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

## Setup

### Setup without docker

This assumes you have postgres installed in running... this can be a hassle. It
might be easier to setup via docker.

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

Run specs `dcrspec`
Run rubocop `dccop`
Run rails console `dccon`
Run postgres console `dcpsql`

## Heroku

url: https://nomisito-46f260c218eb.herokuapp.com/

bundle lock --add-platform x86_64-linux
git push heroku main
add env keys to heroku
heroku logs --tails
heroku run rake db:migrate

## Yard Documentation

Put yard doc in public to easily view on live site
`echo --output-dir public/doc >> .yardopts`

Cheat sheets:
* https://gist.github.com/chetan/1827484
* https://kapeli.com/cheat_sheets/Yard.docset/Contents/Resources/Documents/index

Build yard docs: `yard`
View docs: `yard server` then open https://localhost:8808

[Live on Heroku Docs](https://nomisito-46f260c218eb.herokuapp.com/doc/index.html)

