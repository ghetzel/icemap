START_DATE  = 2004-01-01
DIFF_DAYS  ?= $(shell echo $$(( ($(shell date '+%s') - $(shell date -d '$(START_DATE)' '+%s')) / 86400 )))
CICE_DATES  = $(shell bash -c 'echo {0..$(DIFF_DAYS)} | tr '[:space:]' "\n" | while read d; do date -d "$(START_DATE) + $${d} day" "+%Y%m%d"; done')
CICE_FILES  = $(addprefix images/,$(addsuffix .png,$(addprefix CICE_combine_thick_SM_EN_,$(CICE_DATES))))
FPS        ?= 60
CLEANCMD    = find images -type f -size '-1024c' -print -delete

fetch: clean $(CICE_FILES)
	@$(CLEANCMD)
$(CICE_FILES):
	@test -f $(@) || echo "fetch: $(@)" && curl -sLo "$(@)" "http://polarportal.dk/fileadmin/polarportal/sea/$(notdir $(@))"

clean:
	@$(CLEANCMD)

movie: clean
	@ffmpeg -y -r $(FPS) -pattern_type glob -i 'images/*.png' -c:v libx264 map.mp4
