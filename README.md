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

```
rake db:create
rake db:migrate
rake setup:reset
```

## Heroku

url: https://nomisito-46f260c218eb.herokuapp.com/

bundle lock --add-platform x86_64-linux
git push heroku main
add env keys to heroku
heroku logs --tails
heroku run rake db:migrate

heroku run rails console
ApiRecipe::GuacIsExtra.reset_cache!
ApiRecipe::GuacIsExtra.cache_ingredients
ApiRecipe::Edamam.fetch_all_dietary(site_klass: 'ApiRecipe::GuacIsExtra')
Dietary.reset!

## Yard Documentation

Cheat sheets:
* https://gist.github.com/chetan/1827484
* https://kapeli.com/cheat_sheets/Yard.docset/Contents/Resources/Documents/index

Build yard docs: `yard`
View docs: `yard server` then open https://localhost:8808
