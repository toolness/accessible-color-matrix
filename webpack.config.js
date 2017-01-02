module.exports = {
  entry: './src/index.js',
  output: {
    path: './static',
    filename: 'bundle.js'
  },
  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },
  module: {
    loaders: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack'
    }],
    noParse: /\.elm$/
  },
  devServer: {
    inline: true,
    stats: 'errors-only'
  }
};
