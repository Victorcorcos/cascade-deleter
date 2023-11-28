<p align="center">
  <img src="https://i.imgur.com/wUx1CYi.png" alt="Cascade Delete" width="200" height="200"/>
</p>

<p align="center">
Cascade Deleter is a ruby gem designed to delete a set of items with all of their children, grandchildren, grandgrandchildren, i.e. delete items and all of their descending hierarchy.
</p>


## Why it is necessary? 💡

Currently, **Rails** doesn't have a builtin one-liner way to delete items with all of their descending hierarchy, this type of deletion requires manual and tedious work, since you need to discover which items should be deleted for each descending classes, one by one.

**Well, `CascadeDeleter` solves this issue perfectly with a oneliner command 🏆**

```rb
CascadeDeleter.new(MyModel.where(my_query)).delete_all
```


## Example 🧑‍🏫

As an illustrative example, let's think about the following classes structure:

1. Class `Person` has_many books
2. Class `Book` has_many pages
3. Class `Page` has_many words
4. Class `Word`

That means: `Person` is parent of a list of `Book`s, which is parent of a list of `Page`s, which is parent of a list of `Word`s.

Now, imagine that you want to delete people with `id = 1`, `id = 2` and `id = 3` of the following hierarchy:

#### Hierarchy

<p align="center">
  <img src="https://i.imgur.com/90LZXUj.png" alt="Hierarchy"/>
</p>

The correct solution would be to to delete it from the leaves to the root, which means deleting the items on this order:

#### Deletions Order

① → ② → ③ → 🚩

<p align="center">
  <img src="https://i.imgur.com/uaf1R02.png" alt="Deletion Order"/>
</p>

⤷ That means...

①. Delete the `words` that belongs to these `people` through the `word` → `page` → `book` → `people` relationship.

(`Word A`, `Word B`, `Word C`, `Word D`, `Word E`, `Word F`, `Word G`, `Word H`, `Word I`)

②. Delete the `pages` that belongs to these `people` through the `page` → `book` → `people` relationship.

(`Page A`, `Page B`, `Page C`, `Page D`, `Page E`, `Page F`, `Page G`)

③. Delete the `books` that belongs to these `people` through the `book` → `people` relationship.

(`Book 1`, `Book 2`, `Book 3`, `Book 4`)

🚩. Finally deleting the `people`

(`Person 1`, `Person 2`, `Person 3`)

With the `cascade-deleter` gem, **these deletions will be done automatically just executing the following oneliner command 🏆**

```rb
CascadeDeleter.new(Person.where(id: [1, 2, 3]).delete_all
# "Person.where(id: [1, 2, 3])" is used for this example, but you can place any ActiveRecord Relation as an argument here!
```


## Installation ⚙️

Add `cascade-deleter` to your Gemfile.

```rb
gem 'cascade-deleter'
```


## Usage 🚀

Just require the `cascade_deleter` library and use it! (You can test this on `rails console`)

### Usage ①
**Hard** Delete of inactive Projects

```rb
CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all
```

### Usage ②
**Hard** Delete of inactive Projects by skipping some classes

```rb
CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all(
  except: ['Audited::Audit', 'Picture', 'Attachment']
)
```

### Usage ③
**Hard** Delete of inactive Projects overriding the `joins` parameter.

You can override the `joins` parameter through the `custom_joins` attribute if you want more accurate relationships
*in case the `joins` is not provided (**Usage ①**), the shortest path between each children class and the root class will be chosen for each join*

```rb
CascadeDeleter.new(Project.unscoped.where(active: false)).delete_all(
  custom_joins: {
    'Attachment' => {:subproject=>:project}
  }
)
```

⤷ That means: When deleting the `Attachment` descending class of `Project`, the following statement will be executed:

```rb
Attachment.joins({:subproject=>:project}).where(projects: { active: false }).delete_all
```

### Usage ④
**Soft** Delete of *TO BE DELETED* Disciplines

```rb
CascadeDeleter.new(Discipline.where(description: '[TO BE DELETED]')).delete_all(
  method: :soft
)
```

⚠️ When using **Soft** deletion (`method: :soft`), be aware that the `active` *boolean* parameter of your database tables will be used, so you need to have the `active` *boolean* parameter in your database tables when using **Soft** deletion.

```rb
t.boolean "active", default: true
```

#### Why not use `dependent: :delete` / `dependent: :delete_all` instead of `CascadeDeleter`? 🤔

1. 𝐒𝐢𝐦𝐩𝐥𝐢𝐜𝐢𝐭𝐲

The "dependent" solution not only will require you to add `dependent: :delete` / `dependent: :delete_all` on all the models you want to perform the cascade deletion, but it will still raise the `Mysql2::Error: Cannot delete or update a parent row` MySQL error while deleting the root items in case you don't have all of your database foreign keys setted up with `foreign_key: { on_delete: :cascade }`.

So, for example, if you want to delete 10 Projects that has 50 descending application models, you would need to add `dependent: :delete` / `dependent: :delete_all` on the 50 application models as well as executing new migrations changing all of the foreign keys of each one of these **50 tables** to `foreign_key: { on_delete: :cascade }`.

In a comparison, if you decide to use `CascadeDeleter`, you would just need to execute this one-liner command which achieves the same goal:

```rb
CascadeDeleter.where(Project.where(id: (1..10))).delete_all
```

2. 𝐅𝐥𝐞𝐱𝐢𝐛𝐢𝐥𝐢𝐭𝐲

Another advantage is that you can perform **Soft Deletions** instead of **Hard Deletions** on your data, which can be very in handy for systems where you want to deactivate items instead of removing them completely from the database.

```rb
CascadeDeleter.where(Project.where(id: (1..10))).delete_all(method: :soft)
```

3. 𝐏𝐞𝐫𝐟𝐨𝐫𝐦𝐚𝐧𝐜𝐞

Finally, you can also decide to delete a set of root items instead of deleting these root items one-by-one. This can be shown on the above examples, which deletes 10 Projects instead of deleting the projects individually. This fact increases the performance, since a single SQL delete operation is executed for a desired table. This process is also applied on the descending classes.

## Contact

* [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/)

---

*This repository is maintained and developed by [Victor Cordeiro Costa](https://www.linkedin.com/in/victor-costa-0bba7197/). For inquiries, partnerships, or support, don't hesitate to get in touch.
