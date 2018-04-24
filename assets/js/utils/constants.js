export default {
  DATATABLE_BASE_CONFIG: {
    autoWidth: false,
    dom: '<"row"<"col-sm-6 order-sm-2"f><"col-sm-6 order-sm-1"i>>t',
    fixedHeader: {
      header: true,
      headerOffset: 53
    },
    language: {
      info: 'Showing _TOTAL_ / _MAX_',
      infoEmpty: 'Showing _TOTAL_ / _MAX_',
      infoFiltered: '',
      search: '',
      searchPlaceholder: 'Search...'
    },
    order: [[0, 'asc']],
    responsive: {
      breakpoints: [
        { name: 'xl', width: Infinity },
        { name: 'lg', width: 1200 },
        { name: 'md', width: 992 },
        { name: 'sm', width: 768 },
        { name: 'xs', width: 576 },
        { name: 'ba', width: 320 }
      ]
    },
    paging: false,
    rowId: 'row_id',
    safeState: true
  }
};
