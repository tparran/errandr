class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :user_id
      t.string :price
      t.string :image
      t.string :url
      t.string :name

      t.timestamps

    end
  end
end
