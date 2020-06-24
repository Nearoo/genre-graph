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
* `app/entry.coffee` and everything it imports

SASS is rendered on-demand.

## Project structure

Place | Meaning
--- | ---
`app/` | Contains coffee & css source files for developement
`app/entry.coffee` | Frontend entry point. Is bundled by webpack on change along with anything it imports, saved into `public/js/app.bundle.js`
`app/style/*.sass` | Style files rendered to css  *on-demand into `public/css/`, keeping filenames. **Note: Put resources referenced in sass file (e.g. fonts) into public/css/...**
`app/style/style.sass` | main css file, included in every page 
`app.coffee` | Backend entry point, sets up webpack, coffee, sass etc.
`bin/main.coffee` | Instanciates server
`view/` | Contains pug files, `view/index/meta/index.pug` is loaded as index; edit `view/index/content.pug` to add content to `<body></body>`
`routes/` | Routes, like the one point to `index.pug`
`public/` | Contains files accessible from client; e.g. request `images/foo.png` returns `public/images/foo.png`. `.js` and `.css` are generated from source in `app` dir, other files can be placed for easy access
