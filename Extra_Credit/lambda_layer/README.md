## Lambda layers

So you're realized that to deploy that lambda, you need to set up a Lambda layer (as it references axios). If you've never done this before, it's pretty easy. If you don't want to go through the effort, you can simply re-use the [layer I created](axios-layer.zip).

### Creating your own layer
To create your own layer, do the following from the console:

`$ mkdir nodejs`

cd into that directory

`$ npm init`

And answer the questions. It doesn't really matter what you specify, as long as your package name doesn't have the same name as the libraries you're trying to import.

Now install all modules locally like this:

`$ npm install --save module1 module2 ...`

Your directory structure should look something like this:

````
nodejs
|-- package.json
|-- node_modules
    |-- node_module1
    |-- node_module2
````
    
Now just zip up the nodejs directory. From here, go into Lambda, select Layers, and upload this as a new Layer. Once this is set as a layer, you can go into your function and add it as a layer. At this point, your function can reference and call modules that are in your layer.
