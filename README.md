*  [Roadmap, Screenshots, Goal on Notion](https://www.notion.so/Music-Graph-5119dce2c5464bbfb501736d444004f5)
# Setup

Install node pkgs:

    yarn install

Start server:

    yarn start

Server will reload on change in
* `app.coffee`
* `webpack.config.coffee`

Wepack renders on change in 
* `src/entry.coffee` and everything it imports

SASS is rendered on-demand.

## Project structure

Place | Meaning
--- | ---
`src/` | Countains all frontend source: js as coffee, html as pug, css as scss
`public/` | Contains files accessible from client; e.g. request `images/foo.png` returns `public/images/foo.png`. `js/` and `css/` dir are filled outomatically with rendered content from `src/`
`src/entry.coffee` | Frontend entry point. Is bundled by webpack on change along with anything it imports, saved into `public/js/app.bundle.js`
`src/pug/index/meta/index.pug` | Loaded as index
`src/css/style.sass` | main css file, included in every page 
`app.coffee` | Backend entry point, sets up webpack, coffee, sass etc.



