(function($) {
	$.fn.showMore = function (options) {

		// Default showmore
		var defaults = {
			speedDown : 300,
			speedUp : 300,
			height : '100px',
			showText : '<i class="fas fa-chevron-down"></i>',
			hideText : '<i class="fas fa-chevron-up"></i>'
		};

		var options = $.extend(defaults, options);

		return this.each(function() {
			var $this = $(this);
			options.height = $this.height();
			$this.css('height', 'auto');
			var $showMoreOrgHeight = $this.height();
			$this.css('height', options.height);

			if($showMoreOrgHeight > parseInt(options.height)) {
				$this.wrapInner('<div class="showmore_content" />');
				$this.find('.showmore_content').css('height', options.height);
				$this.append('<div class="showmore_trigger"><span class="more">' + options.showText + '</span><span class="less" style="display:none;">' + options.hideText + '</span></div>')
				$this.find('.showmore_trigger').on('click', '.more', function (){
					$(this).hide();
					$(this).next().show();
					var $triggerHeight = $this.find('.showmore_trigger').height();
					$(this).parent().prev().animate({ height: $showMoreOrgHeight+$triggerHeight }, options.speedDown);
				});
				$this.find('.showmore_trigger').on('click', '.less', function(){
					$(this).hide();
					$(this).prev().show();
					$(this).parent().prev().animate({ height: options.height }, options.speedUp);
				});
			}
			$this.css('height', 'auto');
			$this.css({opacity: 1});
		});

	};
})(jQuery);