'use strict';

var path = require('path');
var webpack = require('webpack');
var merge = require('webpack-merge');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');

var ENVIRONMENT = process.env.NODE_ENV || 'development';
var ROOT_PATH = path.resolve(__dirname);
var CLIENT_PATH = path.resolve(ROOT_PATH, 'client');
var BUILD_PATH = path.resolve(ROOT_PATH, 'public');

var config = {
  common: {
    entry: [
      CLIENT_PATH
    ],
    output: {
      path: BUILD_PATH,
      publicPath: '/',
      filename: '[name].js',
      hash: true
    },
    plugins: [
      new webpack.optimize.OccurenceOrderPlugin(),
      new HtmlWebpackPlugin({
        template: path.resolve(CLIENT_PATH, 'index.tpl.html'),
        inject: 'body',
        filename: 'index.html'
      }),
      new webpack.DefinePlugin({
        __FAYE_CLIENT_URL__: (ENVIRONMENT === 'production' ? "'/bayeux'" : "'ws://localhost:5000/bayeux'")
      })
    ],
    module: {
      loaders: [{
        test: /\.jsx?$/,
        include: [CLIENT_PATH],
        loaders: ['react-hot', 'babel']
      }, {
        test: /\.scss$/,
        loader: 'style!css?modules&importLoaders=1&localIdentName=[name]__[local]___[hash:base64:5]!postcss!sass'
      }, {
        test: /\.(css)(\?.+)?$/,
        loader: 'style!css'
      }, {
        test: /\.(ttf|eot|svg|otf|svg|woff|woff2)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file-loader"
      }, {
        test: /\.(jpe?g|png|gif)$/i,
        loaders: ['url?limit=8192', 'img']
      }]
    },
    postcss: [
      require('autoprefixer')
    ],
    resolve: {
      extensions: ['', '.js', '.jsx']
    }
  },

  development: {
    devtool: 'eval-source-map',
    entry: [
      'webpack-dev-server/client?http://localhost:3000',
      'webpack/hot/dev-server'
    ],
    plugins: [
      new webpack.HotModuleReplacementPlugin(),
      new webpack.NoErrorsPlugin()
    ],
    output: {

    }
  },

  production: {
    output: {
      filename: '[name]-[hash].min.js'
    },
    plugins: [
      new ExtractTextPlugin('[name]-[hash].min.css'),
      new webpack.optimize.UglifyJsPlugin({
        compressor: {
          warnings: false,
          screw_ie8: true
        }
      })
    ],

  }
}

module.exports = merge(config.common, config[ENVIRONMENT]);
