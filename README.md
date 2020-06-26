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
* `src/entry.coffee` or anything it imports

Stylus-file are rendered on-demand.

## Project structure

Place | Meaning
--- | ---
`src/` | Contains all frontend source: js as coffee, html as pug, css as sass
`public/` | Contains files exposed to public via webserver. E.g. request `images/foo.png` returns `public/images/foo.png`. `js/` and `css/` dir are filled automatically with rendered content from `src/`
`src/entry.coffee` | Frontend entry point. Bundled by webpack on change along with anything it imports, then stored at `public/js/app.bundle.js`
`src/pug/index/index.pug` | Loaded as index
`src/style/style.styl` | main css file, included on every page 
`app.coffee` | Backend entry point, sets up webpack, coffee, stylus etc.



