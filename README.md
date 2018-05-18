# Day One to WordPress

Ruby script to migrate your Day One JSON archive into WordPress:

- imports your Day One entries as private posts
- uploads your photos and inserts them into your entries
- add custom fields for location data (you can use these fields in your template to show the location of a post)

### Setup

1. [Export your Day One archive in JSON format][1]
2. Install rubypress via `sudo gem install rubypress`
3. Unzip your Day One archive and config the path to it ([line 7][2])
4. Set your Day One journal JSON file you want to import from ([line 8][3])
5. Add credentials for your WordPress blog ([line 9][4])
6. Run the script via `ruby path/to/import.rb`, it should output parsed data for each entry as it does the import

[1]:	http://help.dayoneapp.com/tips-and-tutorials/exporting-entries
[2]:	https://github.com/zsbenke/dayone-to-wordpress/blob/master/day_one_to_wordpress.rb#L7
[3]:	https://github.com/zsbenke/dayone-to-wordpress/blob/master/day_one_to_wordpress.rb#L8
[4]:	https://github.com/zsbenke/dayone-to-wordpress/blob/master/day_one_to_wordpress.rb#L9