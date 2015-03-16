bootstrap:
	bundle install
	@echo "\nSetting up API Keys, leave blank if you don't know."
	@printf '\nWhat is your Giphy API Key ( use the one on https://github.com/Giphy/GiphyAPI if you do not have one )? '; \
		read GIPHY_API_KEY; \
	
	bundle exec pod keys set GiphyAPIKey "$$GIPHY_API_KEY" GIFs
	pod install
