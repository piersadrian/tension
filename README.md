Tension
=======
_Tighten up Rails's asset pipeline for CSS & JS._

Rails's asset pipeline is smart and well–implemented under the hood, but it can
be a challenge to organize your CSS and JavaScript so that you don't have to
struggle to maintain which files get compiled, where they live, and how they're
included in views and templates.

_Tension_ helps you out. It takes Rails's existing controller/view file structure
and applies it to JavaScript and CSS assets as well. Let's take a sample Rails app:

    app
    + assets
    + controllers
      + account
      + api
      + blog
        + posts_controller.rb
    + models
    + views
      + account
      + api
      + blog
        + posts
          + index.html.erb
      + layouts
        + blog.html.erb

The standard structure Rails enforces is __module__ &rarr; __controller__ &rarr;
__action__. For the PostsController, the __action__ logic is tucked away alongside
other actions in `posts_controller.rb`, but its view is a separate file namespaced
under the _blog_ module and _posts_ controller.

This is a logical, intuitive structure. Our assets should follow it too.

Using Rails's asset pipeline you can drop an asset anywhere within the `assets`
directory and Rails will compile and serve it, but Rails enforces no logical
structure on your files. This leads to messy, hard-to-maintain code, and it gets
worse when you precompile assets in production.

...
