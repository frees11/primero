var ReportingLocationStringSources = _primero.Collections.StringSources.LocationStringSources.extend({
  findLocations: function (term) {
    var regex = new RegExp(term, 'i');
    var model = _.first(_.filter(this.models, function(model){ return model.get('type') == 'ReportingLocation' })).attributes

    return _.filter(model.options, function(opt) {
      return regex.test(opt.display_text)
    })
  }
})

_primero.Views.PopulateReportingLocationSelectBoxes = _primero.Views.PopulateLocationSelectBoxes.extend({
  el: "form select[data-populate='ReportingLocation']",
  initialize: function() {
    var self = this;

    this.option_string_sources = ['ReportingLocation']

    this.$el.on('chosen:ready', function(e) {
      self.initAutoComplete($(e.target))
    })

    _primero.populate_reporting_location_select_boxes = function() {
      if (self.$el.length) {
        self.collection = new ReportingLocationStringSources();

        self.collection.fetch()
          .done(function() {
            self.parseOptions();
          })
          .fail(function() {
            self.collection.message = I18n.t('messages.string_sources_failed')
            self.disableAjaxSelectBoxes();
          })
      }
    }

    _primero.populate_reporting_location_select_boxes();
  }
})
