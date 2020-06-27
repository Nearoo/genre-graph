path = require('path')

module.exports =
    entry: 
        app: './src/entry.coffee'
    output:
        path: path.join(__dirname, 'public', 'js')
        filename: '[name].bundle.js'
    module: 
        rules: [
            {
                test: /\.coffee$/,
                loader: 'coffee-loader',
            }
        ]
    devtool: '#eval-source-map'
    node: 
        fs: 'empty'