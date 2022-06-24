class CreateConnections < ActiveRecord::Migration[7.0]
  def change
    create_table :connections do |t|
      t.string :tg_token
      t.string :site
      t.string :email
      t.string :api_token

      t.timestamps
    end
  end
end
