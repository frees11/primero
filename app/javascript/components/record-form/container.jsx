import { useEffect, useState } from "react";
import PropTypes from "prop-types";
import { useMediaQuery } from "@material-ui/core";
import { batch, useDispatch } from "react-redux";
import { makeStyles } from "@material-ui/core/styles";
import { useLocation, useParams, useHistory } from "react-router-dom";
import clsx from "clsx";
import { fromJS } from "immutable";

import FormFilters from "../form-filters";
import { useMemoizedSelector, useThemeHelper } from "../../libs";
import { useI18n } from "../i18n";
import PageContainer from "../page";
import Transitions from "../transitions";
import LoadingIndicator from "../loading-indicator";
import {
  clearSelectedRecord,
  fetchRecord,
  getIncidentFromCase,
  saveRecord,
  selectRecord,
  setSelectedRecord,
  getCaseIdForIncident
} from "../records";
import {
  APPROVALS,
  RECORD_TYPES,
  RECORD_OWNER,
  TRANSITION_TYPE,
  RECORD_PATH,
  REFERRAL,
  INCIDENT_FROM_CASE,
  CHANGE_LOGS,
  SUMMARY
} from "../../config";
import { ACTIONS, SHOW_FIND_MATCH } from "../../libs/permissions";
import { SHOW_CHANGE_LOG } from "../permissions";
import RecordOwner from "../record-owner";
import Approvals from "../approvals";
import IncidentFromCase from "../incidents-from-case";
import ChangeLogs from "../change-logs";
import { getIsProcessingSomeAttachment, getLoadingRecordState, getRecordAttachments } from "../records/selectors";
import { usePermissions } from "../user";
import { clearRecordAttachments, fetchRecordsAlerts } from "../records/action-creators";
import { getPermissionsByRecord, getPermittedFormsIds } from "../user/selectors";
import Summary from "../summary";
import { RESOURCES } from "../permissions/constants";
import { useApp } from "../application";
import useIncidentFromCase from "../records/use-incident-form-case";
import SaveAndRedirectDialog from "../save-and-redirect-dialog";

import {
  getAttachmentForms,
  getFirstTab,
  getFormNav,
  getRecordForms,
  getLoadingState,
  getErrors,
  getRecordFormsByUniqueId,
  getSelectedForm,
  getShouldFetchRecord
} from "./selectors";
import { clearValidationErrors, setPreviousRecord } from "./action-creators";
import { NAME } from "./constants";
import Nav from "./nav";
import { RecordForm, RecordFormToolbar } from "./form";
import styles from "./styles.css";
import { compactValues, getRedirectPath } from "./utils";

const useStyles = makeStyles(styles);

const Container = ({ mode }) => {
  let submitForm = null;
  const { theme } = useThemeHelper({ css: styles });
  const mobileDisplay = useMediaQuery(theme.breakpoints.down("sm"));
  const { demo } = useApp();
  const params = useParams();
  const { state: locationState } = useLocation();
  const history = useHistory();

  const containerMode = {
    isNew: mode === "new",
    isEdit: mode === "edit",
    isShow: mode === "show"
  };

  const css = useStyles();
  const dispatch = useDispatch();
  const i18n = useI18n();

  const recordType = RECORD_TYPES[params.recordType];

  const incidentFromCase = useMemoizedSelector(state => getIncidentFromCase(state, recordType));
  const fetchFromCaseId = useMemoizedSelector(state => getCaseIdForIncident(state, recordType));
  const record = useMemoizedSelector(state => selectRecord(state, containerMode, params.recordType, params.id));
  const userPermittedFormsIds = useMemoizedSelector(state => getPermittedFormsIds(state));

  const canViewCases = usePermissions(params.recordType, ACTIONS.READ);
  const canViewSummaryForm = usePermissions(RESOURCES.potential_matches, SHOW_FIND_MATCH);

  const selectedModule = {
    recordType,
    primeroModule: record ? record.get("module_id") : params.module,
    formsIds: userPermittedFormsIds,
    i18n,
    renderCustomForms: canViewSummaryForm
  };

  const {
    handleCreateIncident,
    redirectDialogOpen,
    closeRedirectDialog,
    setSaveCaseBeforeRedirect,
    setCaseIncidentData,
    saveBeforeIncidentRedirect,
    dialogParams
  } = useIncidentFromCase({
    record,
    mode: containerMode
  });
  const userPermissions = useMemoizedSelector(state => getPermissionsByRecord(state, params.recordType));
  const formNav = useMemoizedSelector(state => getFormNav(state, selectedModule, userPermissions));
  const forms = useMemoizedSelector(state => getRecordForms(state, selectedModule));
  const attachmentForms = useMemoizedSelector(state => getAttachmentForms(state));
  const firstTab = useMemoizedSelector(state => getFirstTab(state, selectedModule));
  const loadingForm = useMemoizedSelector(state => getLoadingState(state));
  const loadingRecord = useMemoizedSelector(state => getLoadingRecordState(state, params.recordType));
  const errors = useMemoizedSelector(state => getErrors(state));
  const selectedForm = useMemoizedSelector(state => getSelectedForm(state));
  const isProcessingSomeAttachment = useMemoizedSelector(state =>
    getIsProcessingSomeAttachment(state, params.recordType)
  );
  const recordAttachments = useMemoizedSelector(state => getRecordAttachments(state, params.recordType));
  const summaryForm = useMemoizedSelector(state =>
    getRecordFormsByUniqueId(state, { ...selectedModule, formName: SUMMARY, getFirst: true })
  );
  const shouldFetchRecord = useMemoizedSelector(state => getShouldFetchRecord(state, params));

  const handleFormSubmit = e => {
    if (submitForm) {
      submitForm(e);
    }
  };

  const [toggleNav, setToggleNav] = useState(false);

  const handleToggleNav = () => {
    setToggleNav(!toggleNav);
  };

  const formProps = {
    onSubmit: (initialValues, values) => {
      const saveMethod = containerMode.isEdit ? "update" : "save";
      const { incidentPath, ...formValues } = values;

      const body = {
        data: {
          ...(containerMode.isEdit ? compactValues(formValues, initialValues) : formValues),
          ...(!containerMode.isEdit ? { module_id: selectedModule.primeroModule } : {}),
          ...(fetchFromCaseId ? { incident_case_id: fetchFromCaseId } : {})
        }
      };
      const message = () => {
        return containerMode.isEdit
          ? i18n.t(`${recordType}.messages.update_success`, {
              record_id: record.get("short_id")
            })
          : i18n.t(`${recordType}.messages.creation_success`, recordType);
      };

      batch(() => {
        if (saveBeforeIncidentRedirect) {
          setCaseIncidentData(formValues);
        }

        dispatch(
          saveRecord(
            params.recordType,
            saveMethod,
            body,
            params.id,
            message(),
            i18n.t("offline_submitted_changes"),
            getRedirectPath(containerMode, params, fetchFromCaseId),
            true,
            "",
            Boolean(incidentFromCase?.size),
            selectedModule.primeroModule,
            incidentPath,
            i18n.t("offline_submitted_changes")
          )
        );
      });
      // TODO: Set this if there are any errors on validations
      // setSubmitting(false);
    },
    bindSubmitForm: boundSubmitForm => {
      submitForm = boundSubmitForm;
    },
    handleToggleNav,
    mobileDisplay,
    selectedForm,
    forms,
    mode: containerMode,
    record,
    incidentFromCase,
    fetchFromCaseId,
    recordType: params.recordType,
    primeroModule: selectedModule.primeroModule
  };

  const toolbarProps = {
    mode: containerMode,
    params,
    recordType,
    handleFormSubmit,
    caseIdDisplay: record ? record.get("case_id_display") : null,
    shortId: record ? record.get("short_id") : null,
    primeroModule: selectedModule.primeroModule,
    record
  };

  const navProps = {
    firstTab,
    formNav,
    handleToggleNav,
    isNew: containerMode.isNew,
    mobileDisplay,
    recordType: params.recordType,
    selectedForm,
    selectedRecord: record ? record.get("id") : null,
    toggleNav,
    primeroModule: selectedModule.primeroModule,
    hasForms: !loadingForm && forms.size > 0
  };

  useEffect(() => {
    if (params.id && !loadingRecord && recordAttachments.size && !isProcessingSomeAttachment) {
      dispatch(clearRecordAttachments(params.id, params.recordType));
    }
  }, [loadingRecord, isProcessingSomeAttachment, recordAttachments.size]);

  const canSeeChangeLog = usePermissions(params.recordType, SHOW_CHANGE_LOG);
  const isNotANewCase = !containerMode.isNew && params.recordType === RECORD_PATH.cases;
  const isCaseIdEqualParam = params?.id === record?.get("id");

  useEffect(() => {
    return () => {
      dispatch(setPreviousRecord(fromJS({ id: params.id, recordType: params.recordType })));
    };
  }, []);

  useEffect(() => {
    batch(() => {
      if (params.id) {
        dispatch(setSelectedRecord(params.recordType, params.id));

        if (!locationState?.preventSyncAfterRedirect && shouldFetchRecord) {
          dispatch(fetchRecord(params.recordType, params.id));
          dispatch(fetchRecordsAlerts(params.recordType, params.id));
          dispatch(setPreviousRecord(fromJS({ id: params.id, recordType: params.recordType })));
        }
      }
    });

    history.replace(history.location.pathname, {});
  }, [params.id, params.recordType, shouldFetchRecord]);

  useEffect(() => {
    return () => {
      batch(() => {
        dispatch(clearSelectedRecord(params.recordType));
        dispatch(clearValidationErrors());

        if (params.id) {
          dispatch(clearRecordAttachments(params.id, params.recordType));
        }
      });
    };
  }, []);

  const transitionProps = {
    fetchable: isNotANewCase,
    isReferral: REFERRAL === selectedForm,
    recordType: params.recordType,
    recordID: params.id,
    showMode: containerMode.isShow,
    mobileDisplay,
    handleToggleNav
  };

  const approvalSubforms = record?.get("approval_subforms");
  const incidentsSubforms = record?.get("incident_details");

  const externalForms = (form, setFieldValue, handleSubmit, values) => {
    const isTransitions = TRANSITION_TYPE.includes(form);

    const externalFormSelected = isTransitions ? TRANSITION_TYPE : form;

    return {
      [RECORD_OWNER]: (
        <RecordOwner
          record={record}
          recordType={params.recordType}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
        />
      ),
      [APPROVALS]: (
        <Approvals approvals={approvalSubforms} mobileDisplay={mobileDisplay} handleToggleNav={handleToggleNav} />
      ),
      [INCIDENT_FROM_CASE]: (
        <IncidentFromCase
          record={record}
          incidents={incidentsSubforms}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          mode={containerMode}
          setFieldValue={setFieldValue}
          handleSubmit={handleSubmit}
          recordType={params.recordType}
          primeroModule={selectedModule.primeroModule}
          handleCreateIncident={handleCreateIncident}
        />
      ),
      [TRANSITION_TYPE]: <Transitions {...transitionProps} />,
      [CHANGE_LOGS]: (
        <ChangeLogs
          recordID={params.id}
          fetchable={canSeeChangeLog}
          recordType={params.recordType}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          primeroModule={selectedModule.primeroModule}
          selectedForm={selectedForm}
        />
      ),
      [SUMMARY]: (
        <Summary
          record={record}
          recordType={params.recordType}
          mobileDisplay={mobileDisplay}
          handleToggleNav={handleToggleNav}
          form={summaryForm}
          mode={containerMode}
          userPermittedFormsIds={userPermittedFormsIds}
          values={values}
        />
      )
    }[externalFormSelected];
  };

  // eslint-disable-next-line react/display-name, react/no-multi-comp, react/prop-types
  const externalComponents = ({ setFieldValue, values }) => (
    <SaveAndRedirectDialog
      open={redirectDialogOpen}
      closeRedirectDialog={closeRedirectDialog}
      setFieldValue={setFieldValue}
      handleSubmit={handleFormSubmit}
      values={values}
      mode={containerMode}
      recordType={recordType}
      setSaveCaseBeforeRedirect={setSaveCaseBeforeRedirect}
      incidentPath={dialogParams?.get("path")}
    />
  );

  const canSeeForm = !loadingForm && forms.size === 0 ? canViewCases : forms.size > 0 && formNav && firstTab;
  const hasData = Boolean(canSeeForm && (containerMode.isNew || record) && (containerMode.isNew || isCaseIdEqualParam));
  const loading = Boolean(loadingForm || loadingRecord);
  const renderRecordFormToolbar = selectedModule.primeroModule && <RecordFormToolbar {...toolbarProps} />;
  const containerClasses = clsx(css.recordContainer, {
    [css.formNavOpen]: toggleNav && mobileDisplay
  });
  const navContainerClasses = clsx(css.recordNav, { [css.demo]: demo });
  const demoClasses = clsx({ [css.demo]: demo });

  return (
    <PageContainer twoCol>
      <LoadingIndicator hasData={hasData} type={params.recordType} loading={loading} errors={errors}>
        {renderRecordFormToolbar}
        <div className={containerClasses}>
          <div className={navContainerClasses}>
            <Nav {...navProps} />
          </div>
          <div className={`${css.recordForms} ${demoClasses} record-form-container`}>
            <RecordForm
              {...formProps}
              externalForms={externalForms}
              externalComponents={externalComponents}
              selectedForm={selectedForm}
              attachmentForms={attachmentForms}
              userPermittedFormsIds={userPermittedFormsIds}
            />
            <FormFilters
              selectedForm={selectedForm}
              recordType={selectedModule.recordType}
              primeroModule={selectedModule.primeroModule}
              formMode={containerMode}
              showDrawer
            />
          </div>
        </div>
      </LoadingIndicator>
    </PageContainer>
  );
};

Container.displayName = NAME;

Container.propTypes = {
  mode: PropTypes.string.isRequired
};

export default Container;
