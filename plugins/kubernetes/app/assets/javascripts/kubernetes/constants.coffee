((app) ->
  # -------- CLUSTERS --------------
  app.REQUEST_CLUSTERS                  = 'REQUEST_CLUSTERS'
  app.REQUEST_CLUSTERS_FAILURE          = 'REQUEST_CLUSTERS_FAILURE'
  app.RECEIVE_CLUSTERS                  = 'RECEIVE_CLUSTERS'

  app.REQUEST_CLUSTER                   = 'REQUEST_CLUSTER'
  app.REQUEST_CLUSTER_FAILURE           = 'REQUEST_CLUSTER_FAILURE'
  app.RECEIVE_CLUSTER                   = 'RECEIVE_CLUSTER'
  app.START_POLLING_CLUSTER             = 'START_POLLING_CLUSTER'
  app.STOP_POLLING_CLUSTER              = 'STOP_POLLING_CLUSTER'


  app.DELETE_CLUSTER                    = 'DELETE_CLUSTER'
  app.DELETE_CLUSTER_FAILURE            = 'DELETE_CLUSTER_FAILURE'

  app.REQUEST_CLUSTER_EVENTS            = 'REQUEST_CLUSTER_EVENTS'
  app.REQUEST_CLUSTER_EVENTS_FAILURE    = 'REQUEST_CLUSTER_EVENTS_FAILURE'
  app.RECEIVE_CLUSTER_EVENTS            = 'RECEIVE_CLUSTER_EVENTS'

  app.REQUEST_CREDENTIALS               = 'REQUEST_CREDENTIALS'
  app.REQUEST_CREDENTIALS_FAILURE       = 'REQUEST_CREDENTIALS_FAILURE'
  app.RECEIVE_CREDENTIALS               = 'RECEIVE_CREDENTIALS'

  app.REQUEST_SETUP_INFO                = 'REQUEST_SETUP_INFO'
  app.REQUEST_SETUP_INFO_FAILURE        = 'REQUEST_SETUP_INFO_FAILURE'
  app.RECEIVE_SETUP_INFO                = 'RECEIVE_SETUP_INFO'
  app.SETUP_INFO_DATA                   = 'SETUP_INFO_DATA'


  # -------- FORMS --------------
  app.PREPARE_CLUSTER_FORM              = 'PREPARE_CLUSTER_FORM'
  app.RESET_CLUSTER_FORM                = 'RESET_CLUSTER_FORM'
  app.UPDATE_CLUSTER_FORM               = 'UPDATE_CLUSTER_FORM'
  app.UPDATE_NODE_POOL_FORM             = 'UPDATE_NODE_POOL_FORM'
  app.ADD_NODE_POOL                     = 'ADD_NODE_POOL'
  app.DELETE_NODE_POOL                  = 'DELETE_NODE_POOL'
  app.SUBMIT_CLUSTER_FORM               = 'SUBMIT_CLUSTER_FORM'
  app.CLUSTER_FORM_FAILURE              = 'CLUSTER_FORM_FAILURE'
  app.FORM_TOGGLE_ADVANCED_OPTIONS      = 'FORM_TOGGLE_ADVANCED_OPTIONS'
  app.FORM_UPDATE_ADVANCED_VALUE        = 'FORM_UPDATE_ADVANCED_VALUE'
  app.SET_CLUSTER_FORM_DEFAULTS         = 'SET_CLUSTER_FORM_DEFAULTS'



  # -------- METADATA --------------

  app.REQUEST_META_DATA            = 'REQUEST_META_DATA'
  app.REQUEST_META_DATA_FAILURE    = 'REQUEST_META_DATA_FAILURE'
  app.RECEIVE_META_DATA            = 'RECEIVE_META_DATA'

)(kubernetes)
