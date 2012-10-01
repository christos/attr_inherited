## Description

Attribute inheritance for `ActiveRecord` models

Using `attr_inherited` allows your `ActiveRecord` models to inherit any of their attributes from an associated, or parent model.



## Usage

[![Build Status](https://secure.travis-ci.org/christos/attr_inherited.png)](http://travis-ci.org/christos/attr_inherited)

### Inheriting attributes from an associated model

Given a `Post` model and the following `Version` model

    class Version < ActiveRecord::Base
      belongs_to  :post

      attr_inherited :title, :synopsis, from: :post
    end

..then `Version` will now inherit `title` and `synopsis` from the parent post, if either attributes are `nil`

    1.9.3p194 :001 > post = Post.create!(title: "First post", synopsis: "First post synopsis")
    1.9.3p194 :002 > version = Version.create!(post: post)

    1.9.3p194 :003 > version.title
     => "First post"

    1.9.3p194 :004 > version.body
     => "First post body"

You can override any of the inherited attributes by setting its a value to anything other than `nil`

    1.9.3p194 :005 > version.update_attributes(description: "Version synopsis")

    1.9.3p194 :006 > version.synopsis
     => "Version description"

### Renaming inherited attributes

If you want the inherited attribute to have a name other than that of the associated model's attribute, you can use the `as:` option to rename it. For example:

    class Version < ActiveRecord::Base
      belongs_to  :post

      attr_inherited :synopsis, from: :post, as: :description
    end

    1.9.3p194 :001 > post = Post.create!(synopsis: "First post synopsis")
    1.9.3p194 :002 > version = Version.create!(post: post)

    1.9.3p194 :003 > version.description
     => "First post synopsis"

Note that `description` must be an attribute of `Version` for the above to work.

### Inheriting attributes even when they are not `nil`

You might want to inherit an attribute not only when it is `nil` but even when it is an empty string `""`. You can do this by passing a predicate with the `when:` option that would test if the attribute should be inherited.

    class Version < ActiveRecord::Base
      belongs_to  :post

      attr_inherited :title, from: :post, when: :blank?
    end

    1.9.3p194 :001 > post = Post.create!(title: "First post")
    1.9.3p194 :002 > version = Version.create!(post: post)

    1.9.3p194 :003 > version.title
     => "First post"

    1.9.3p194 :004 > version.update_attributes(title: "     ")
    1.9.3p194 :005 > version.title
     => "First post"

### Using the `when:` option to fake has_many association inheritance

Until real association inheritance is implemented you can fake it like this:

    class Version < ActiveRecord::Base
      has_many :comments, as: :commentable
    end

    class Version < ActiveRecord::Base
      belongs_to  :post
      has_many :comments, as: :commentable

      attr_inherited :comments, from: :post, when: :empty?
    end

...which makes `comments` behave almost as if it was inherited from `Post`:

    1.9.3p194 :001 > post = Post.create!(title: "First post")
    1.9.3p194 :002 > post.comments.create(text: "Post comment")
    
    1.9.3p194 :003 > version = Version.create!(post: post)
    1.9.3p194 :004 > version.comments.first.text
     => "Post comment"

    1.9.3p194 :005 > version.comments = [Comment.create(text: "Version comment")]
    1.9.3p194 :006 > version.comments.first.text
     => "Version comment"

**Caveat**: You can't call any other association methods on `version.comments` when it is inherited, such as `<<`, `.create`, `.build`

## Installation

*Requires Rails 3.1+*

Add this line to your application's Gemfile:

    gem 'attr_inherited'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install attr_inherited

## Changelog

**1.0.0** Initial relase (2012-10-02)

## To Do

  * Test assertion of valid parameters
  * Write rdocs
  * Document or remove default `parent` option for `from:` option
  * Properly support inheriting associations
  * Investigate support for virtual attributes (:attr_accessor)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright (c) Christos Zisopoulos, released under the MIT license