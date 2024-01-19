{
  jobs: [
    WeekdayJob.new(:identifier => 'ead',
                   :description => 'Export EAD versions of resource records',
                   :days_of_week => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                   :start_time => '8:30',
                   :end_time => '23:59',
                   :minimum_seconds_between_runs => 5,

                   :task => ExportEADTask,
                   :task_parameters => {
                     # Force this job to create a git commit periodically
                     :commit_every_n_records => 50,
                     :search_options => {
                       :repo_id => 2,
#                       :identifier => 'AAA.02.G',
#                       :start_id => 'AAA.01',
#                       :end_id => 'ZZZ.99',
                     },
                     :export_options => {
                       :include_unpublished => false,
                       :include_daos => true,
                       :numbered_cs => true
                     },

                     :xslt_transforms => ['config/transform.xslt', 'config/changes.xsl'],
#                     :validation_schema => ['config/ead.xsd'],
#                     :xslt_transforms => ['config/changes2.xsl'],
#                     :schematron_checks => ['config/schematron.sch'],
                   },

                   :before_hooks => [
                     ShellRunner.new("mkdir -p \"$EXPORT_DIRECTORY\""),
                   ],
                   :after_hooks => [
                    FopPdfGenerator.new('config/as-ead-pdf.xsl'),
                    ErbRenderer.new("templates/manifest.md.erb", "README.md"),
                  ]),
                  ]
                  }