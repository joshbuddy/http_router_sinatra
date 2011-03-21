# HttpRouter for Sinatra

## Usage

In your Sinatra app, register your extension

    register HttpRouter::Sinatra::Extension
    
Then, add your routes normally. If you use the :name option when defining your route, you can later generate your route
with the `generate` method.