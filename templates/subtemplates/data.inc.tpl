<?php if($logged_in): ?>
<ul class="breadcrumb">
<li><a href="<?php echo BASE_URL; ?>?r=dashboard#data" title="<?php echo $lang['dashboard_title']; ?>"><?php echo $lang['dashboard_link']; ?></a></li>
<li class="active"><?php echo $subtitle; ?></li>
</ul>
<?php endif; ?>

<div class="row">
<div class="col-sm-8"><h1><?php if($parent_title): ?><span class="parent"><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $parent_table; ?>"><?php echo $parent_title; ?></a></span><br /><span class="child"><?php echo $subtitle; ?></span><?php else: ?><?php echo $subtitle; ?><?php endif; ?></h1></div>
<div class="col-sm-4">
<div class="btn-top-right">
<?php /*if($permission['write'] && !$parent_table): ?><a class="btn btn-success" href="<?php echo BASE_URL; ?>?r=edit_data_item.add&amp;data_id=<?php echo $table_id; ?>"<?php if($data_type==1): ?> onclick="this.href+='&amp;current_position='+map.center.lon+','+map.center.lat+','+map.zoom"<?php endif; ?>><span class="glyphicon glyphicon-plus"></span> <?php echo $lang['add_item_link']; ?></a><?php endif; */ ?>
<div class="btn-group">
<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="glyphicon glyphicon-cog"></span> <?php echo $lang['options_label']; ?> <span class="caret"></span></button>
<ul class="dropdown-menu pull-right" style="text-align:left;">
<li><a href="<?php echo BASE_URL; ?>?r=download_data&amp;id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-cloud-download"></span> <?php echo $lang['download_data_link']; ?></a></li>
<li><a href="<?php echo BASE_URL; ?>?r=download_sheet&amp;id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-list-alt"></span> <?php echo $lang['download_sheet_link']; ?></a></li>
<?php if($permission['manage']||$permission['data_management']): ?>
<li class="divider"></li>
<?php endif; ?>
<?php /*if($permission['manage']): ?>
<li><a href="<?php echo BASE_URL; ?>?r=data_model.edit_model&amp;id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-wrench"></span> <?php echo $lang['edit_data_model_link']; ?></a></li>
<?php endif;*/ ?>
<?php if($permission['data_management']): ?>
<li><a href="<?php echo BASE_URL; ?>?r=data_model.copy_model&amp;id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-share-alt"></span> <?php echo $lang['copy_data_model_link']; ?></a></li>
<li><a href="<?php echo BASE_URL; ?>?r=data_model.delete_model&amp;id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-remove text-danger"></span> <?php echo $lang['delete_data_model_link']; ?></a></li>
<?php endif; ?>
</ul>
</div>
<?php if(isset($help)): ?>
<a class="btn btn-default" href="index.php?r=help.<?php echo $help; ?>" data-toggle="modal" data-target="#modal_help" data-input="content"><span class="glyphicon glyphicon-question-sign"></span> <?php echo $lang['help']; ?></a>
<?php endif; ?>
</div>
</div>
</div>

<ul id="myTab" class="nav nav-tabs">
<?php if($data_type==1): ?><li class="active"><a href="#map" data-toggle="mytab"><?php echo $lang['data_map_title']; ?></a></li> <?php endif; ?>
<li<?php if($data_type==0): ?> class="active"<?php endif; ?>><a href="#items" data-toggle="mytab"><?php echo $lang['data_items_title']; ?></a></li>
<?php if(isset($data_images)): ?>
<li><a href="#images" data-toggle="mytab"><?php echo $lang['data_images']; ?></a></li>
<?php endif; ?>
<li><a href="#properties" data-toggle="mytab"><?php echo $lang['data_properties_title']; ?></a></li>
<li><a href="#structure" data-toggle="mytab"><?php echo $lang['data_structure_title']; ?></a></li>

</ul>

<div id="myTabContent" class="tab-content">

<?php if($data_type==1): ?>

<div id="map" class="mytab-pane mytab-pane-active">

<?php if($permission['write'] && !$parent_table): ?>
<div class="row">
<div class="col-sm-12">
<a class="btn btn-success pull-right bottom-space-small" href="<?php echo BASE_URL; ?>?r=edit_data_item.add&amp;data_id=<?php echo $table_id; ?>"<?php if($data_type==1): ?> onclick="this.href+='&amp;current_position='+map.center.lon+','+map.center.lat+','+map.zoom"<?php endif; ?>><span class="glyphicon glyphicon-plus"></span> <?php echo $lang['add_item_link']; ?></a>
</div>
</div>
<?php endif; ?>

<?php if(isset($_SESSION[$settings['session_prefix'].'usersettings']['disable_map']) && $_SESSION[$settings['session_prefix'].'usersettings']['disable_map']): ?>
<div class="no-map">
<p><span class="glyphicon glyphicon-warning-sign"></span> <?php echo $lang['map_disabled']; ?></p>
</div>
<div class="text-center">
<a class="btn btn-primary" href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;disable_map=0"><?php echo $lang['enable_map']; ?></a></p>
</div>
<?php else: ?>

<div id="mapwrapper">
<div id="mapcontainer" class="defaultmap"<?php if(isset($_SESSION[$settings['session_prefix'].'usersettings']['map_height'])): ?> style="height:<?php echo $_SESSION[$settings['session_prefix'].'usersettings']['map_height']; ?>px"<?php endif; ?>>
<div id="maptoolbar">
<div class="buttongroup">
<a id="zoomwheel" href="#" onclick="toggleZoomWheel(); return false" class="<?php if(isset($_SESSION[$settings['session_prefix'].'usersettings']['map_zoomwheel'])&&$_SESSION[$settings['session_prefix'].'usersettings']['map_zoomwheel']==1): ?>active<?php else: ?>inactive<?php endif; ?>" title="<?php echo $lang['zoomwheel_label']; ?>"><?php echo $lang['zoomwheel_label']; ?></a>
</div>
<div id="mapsizetools" class="buttongroup">
<a id="fullscreenmap" href="#" title="<?php echo $lang['fullscreen_map_label']; ?>"><?php echo $lang['fullscreen_map_label']; ?></a>
<a id="reducemap" href="#" title="<?php echo $lang['reduce_map_label']; ?>"><?php echo $lang['reduce_map_label']; ?></a>
<a id="enlargemap" href="#" title="<?php echo $lang['enlarge_map_label']; ?>"><?php echo $lang['enlarge_map_label']; ?></a>
</div>
</div>
<div id="layerinactivenotice"><?php echo $lang['layer_inactive_message']; ?></div>
<a id="disablemap" href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;disable_map=1" title="<?php echo $lang['disable_map']; ?>">[x]</a>
</div>
</div>

<?php endif; ?>

</div>
<?php endif; ?>

<div id="items" class="mytab-pane<?php if($data_type==0): ?> mytab-pane-active<?php endif; ?>">

<div class="row">
<div class="col-sm-10">
<?php if(isset($filter_columns)): ?>
<form class="form-inline form-filter bottom-space-small" action="<?php echo BASE_URL; ?><?php if($data_type==1): ?>#items<?php endif; ?>" method="get">
<input type="hidden" name="r" value="data" />
<input type="hidden" name="data_id" value="<?php echo $table_id; ?>" />
<input type="hidden" name="p" value="<?php echo $p; ?>" />
<input type="hidden" name="order" value="<?php echo $order; ?>" />
<input type="hidden" name="ipp" value="<?php echo $ipp; ?>" />
<input type="hidden" name="asc" value="<?php echo $asc; ?>" />

<div class="form-group<?php if(isset($filter)): ?>  has-warning<?php endif; ?>">
<input type="text" class="form-control" name="filter" id="filter" value="<?php if(isset($filter)): ?><?php echo $filter; ?><?php endif; ?>" placeholder="<?php echo $lang['filter_label']; ?>">
<select name="filter_id" class="form-control" size="1">
<?php foreach($filter_columns as $filter_column): ?>
<option value="<?php echo $filter_column['id']; ?>"<?php if(isset($filter_id)&&$filter_id==$filter_column['id']): ?> selected<?php endif; ?>><?php echo $filter_column['label']; ?></option>
<?php endforeach; ?>
</select>

<button class="btn btn-default" type="submit" title="<?php echo $lang['filter_title']; ?>"><span class="glyphicon glyphicon-filter"></span></button>
<?php if(isset($filter)): ?><a class="btn btn-warning" href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>" title="<?php echo $lang['filter_remove_title']; ?>"><span class="glyphicon glyphicon-remove"></span></a><?php endif; ?>
</div>
</form>  
<?php endif; ?>
</div>
<div class="col-sm-2">
<?php if($permission['write'] && !$parent_table): ?>
<a class="btn btn-success pull-right bottom-space-small" href="<?php echo BASE_URL; ?>?r=edit_data_item.add&amp;data_id=<?php echo $table_id; ?>"<?php if($data_type==1): ?> onclick="this.href+='&amp;current_position='+map.center.lon+','+map.center.lat+','+map.zoom"<?php endif; ?>><span class="glyphicon glyphicon-plus"></span> <?php echo $lang['add_item_link']; ?></a>
<?php endif; ?>
</div>
</div>

<?php if(isset($data_items)): ?>
<div class="table-data">
<table class="table table-striped table-hover">
<thead>
<tr>

<th class="options-left">&nbsp;</th>

<?php if($parent_title): ?>
<th class="parent"><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;order=fk<?php if($order=='fk'&&!$asc): ?>&amp;asc=1<?php endif; ?>&amp;ipp=<?php echo $ipp; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo str_replace('[column]', $lang['parent_id_column_label'], $lang['order_by']); ?>"><?php echo $lang['parent_id_column_label']; ?><?php if($order=='fk'&&!$asc): ?> <span class="glyphicon glyphicon-chevron-up"></span><?php elseif($order=='fk'&&$asc): ?> <span class="glyphicon glyphicon-chevron-down"></span><?php endif; ?></a></th>
<?php endif; ?>
<?php if(isset($columns)): ?>
<?php foreach($columns as $column): ?>
<?php if($column['type']>0): ?>
<th><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;order=<?php echo $column['name']; ?><?php if($order==$column['name']&&!$asc): ?>&amp;asc=1<?php endif; ?>&amp;ipp=<?php echo $ipp; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo str_replace('[column]', htmlspecialchars($column['label']), $lang['order_by']); ?>"><?php echo truncate(htmlspecialchars($column['label']), 20, true); ?> <?php if($order==$column['name']&&!$asc): ?> <span class="glyphicon glyphicon-chevron-up"></span><?php elseif($order==$column['name']&&$asc): ?> <span class="glyphicon glyphicon-chevron-down"></span><?php endif; ?></a></th>
<?php endif; ?>
<?php endforeach; ?>
<?php endif; ?>

<th><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;order=created<?php if($order=='created'&&!$asc): ?>&amp;asc=1<?php endif; ?>&amp;ipp=<?php echo $ipp; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo str_replace('[column]', $lang['created_column_label'], $lang['order_by']); ?>"><?php echo $lang['created_column_label']; ?><?php if($order=='created'&&!$asc): ?> <span class="glyphicon glyphicon-chevron-up"></span><?php elseif($order=='created'&&$asc): ?> <span class="glyphicon glyphicon-chevron-down"></span><?php endif; ?></a></th>
<th><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;order=last_edited<?php if($order=='last_edited'&&!$asc): ?>&amp;asc=1<?php endif; ?>&amp;ipp=<?php echo $ipp; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo str_replace('[column]', $lang['last_edited_column_label'], $lang['order_by']); ?>"><?php echo $lang['last_edited_column_label']; ?><?php if($order=='last_edited'&&!$asc): ?> <span class="glyphicon glyphicon-chevron-up"></span><?php elseif($order=='last_edited'&&$asc): ?> <span class="glyphicon glyphicon-chevron-down"></span><?php endif; ?></a></th>

<?php if($data_type==1): ?>
<th><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;order=geom<?php if($order=='geom'&&!$asc): ?>&amp;asc=1<?php endif; ?>&amp;ipp=<?php echo $ipp; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo str_replace('[column]', $lang['geometry_column_label'], $lang['order_by']); ?>"><?php echo $lang['geometry_column_label']; ?> <?php if($order=='geom'&&!$asc): ?> <span class="glyphicon glyphicon-chevron-up"></span><?php elseif($order=='geom'&&$asc): ?> <span class="glyphicon glyphicon-chevron-down"></span><?php endif; ?></a></th>
<?php endif; ?>


</tr>
</thead>
  
<tbody>
<?php $i=1; foreach($data_items as $data_item): ?>
<tr id="row-<?php echo $data_item['id']; ?>"<?php if($data_type==1 && empty($data_item['wkt'])): ?> class="no-geometry"<?php endif; ?>>

<td class="options-left"><a class="btn btn-success btn-xs" href="<?php echo BASE_URL; ?>?r=data_item&amp;data_id=<?php echo $table_id; ?>&amp;id=<?php echo $data_item['id']; ?>" title="<?php echo $lang['show_data_item_details']; ?>"><span class="glyphicon glyphicon-eye-open"></span></a><?php if($permission['write']): ?>&nbsp; <!--
--><a class="btn btn-primary btn-xs" href="?r=edit_data_item.edit&amp;data_id=<?php echo $table_id; ?>&amp;id=<?php echo $data_item['id']; ?>" title="<?php echo $lang['edit']; ?>"><span class="glyphicon glyphicon-pencil"></span></a>&nbsp; <!--
--><a class="btn btn-danger btn-xs delete-confirm" href="?r=data.delete&amp;data_id=<?php echo $table_id; ?>&amp;id=<?php echo $data_item['id']; ?>" title="<?php echo $lang['delete']; ?>" data-delete-confirm="<?php echo rawurlencode($lang['delete_data_item_message']); ?>"><span class="glyphicon glyphicon-remove"></span></a><?php endif; ?></td>

<?php if($parent_table): ?><td class="parent"><a class="btn btn-warning btn-xs btn-fw-xs" href="<?php echo BASE_URL; ?>?r=data_item&amp;data_id=<?php echo $parent_table; ?>&amp;id=<?php echo $data_item['fk']; ?>"><?php echo $data_item['fk']; ?></a></td><?php endif; ?>
<?php if(isset($columns)): ?>
<?php foreach($columns as $column): ?>
<?php if($column['type']>0): ?>
<td>
<?php if($column['type']==6): ?>
<?php if($data_item[$column['name']]): ?><span class="glyphicon glyphicon-ok text-success" title="<?php echo $lang['yes']; ?>"></span><?php endif; ?>
<?php elseif(isset($column['choice_labels']) && isset($column['choice_labels'][$data_item[$column['name']]]) && !empty($column['choice_labels'][$data_item[$column['name']]])): ?>
<?php echo $column['choice_labels'][$data_item[$column['name']]]; ?>
<?php else: ?>
<?php echo truncate($data_item[$column['name']], 20, $column['type']==1 ? true : false); ?>
<?php endif; ?>
</td>
<?php endif; ?>
<?php endforeach; ?>
<?php else: ?>
<!--<td><a href="<?php echo BASE_URL; ?>?r=data_item&amp;id=<?php echo $data_item['id']; ?>"><?php echo $data_item['id']; ?></a></td>-->
<?php endif; ?>

<td><span class="date"<?php if($data_item['creator']): ?> title="<?php echo $data_item['creator']; ?>"<?php endif; ?>><?php echo $data_item['created']; ?></span></td>
<td><?php if(isset($data_item['last_edited'])): ?><span class="date"<?php if($data_item['last_editor']): ?> title="<?php echo $data_item['last_editor']; ?>"<?php endif; ?>><?php echo $data_item['last_edited']; ?></span><?php endif; ?></td>

<?php if($data_type==1): ?>
<td><?php if(!empty($data_item['has_geometry'])): ?><span class="glyphicon glyphicon-ok text-success" title="<?php echo $lang['yes']; ?>"></span><?php endif; ?></td>
<?php endif; ?>

</tr>
<?php ++$i; endforeach; ?>
</tbody>
</table>
</div>

<div class="row">
<div class="col-md-6">
<?php echo $lang['displayed_records_label']; ?> / 
<form class="inline" action="<?php echo BASE_URL; ?><?php if($data_type==1): ?>#items<?php endif; ?>" method="get">
<div class="inline">
<input type="hidden" name="r" value="data" />
<input type="hidden" name="data_id" value="<?php echo $table_id; ?>" />
<input type="hidden" name="p" value="<?php echo $p; ?>" />
<input type="hidden" name="order" value="<?php echo $order; ?>" />
<input type="hidden" name="asc" value="<?php echo $asc; ?>" />
<label for="ipp" style="font-weight:normal;"><?php echo $lang['maximum_records_per_page_label']; ?></label> <input id="ipp" class="form-control form-control-small inline" name="ipp" type="text" size="5" value="<?php echo $ipp; ?>" />
</div>
</form>
</div>
<div class="col-md-6">
<?php if($pagination): ?>
<ul class="pagination pull-right nomargin">
<?php if($pagination['previous']): ?><li><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;p=<?php echo $pagination['previous']; ?>&amp;order=<?php echo $order; ?>&amp;asc=<?php echo $asc; ?>&amp;ipp=<?php echo $ipp; ?><?php if(isset($filter)): ?>&amp;filter=<?php echo $filter; ?>&amp;filter_id=<?php echo $filter_id; ?><?php endif; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo $lang['previous_page_title']; ?>"><span class="glyphicon glyphicon-chevron-left"></span></a></li><?php endif; ?>
<?php foreach($pagination['items'] as $item): ?>
<?php if($item==0): ?><li><span>&hellip;</span></li><?php elseif($item==$pagination['current']): ?><li class="active"><span><?php echo $item; ?></span></li><?php else: ?><li><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;p=<?php echo $item; ?>&amp;order=<?php echo $order; ?>&amp;asc=<?php echo $asc; ?>&amp;ipp=<?php echo $ipp; ?><?php if(isset($filter)): ?>&amp;filter=<?php echo $filter; ?>&amp;filter_id=<?php echo $filter_id; ?><?php endif; ?><?php if($data_type==1): ?>#items<?php endif; ?>"><?php echo $item; ?></a></li><?php endif; ?>
<?php endforeach; ?>
<?php if($pagination['next']): ?><li><a href="<?php echo BASE_URL; ?>?r=data&amp;data_id=<?php echo $table_id; ?>&amp;p=<?php echo $pagination['next']; ?>&amp;order=<?php echo $order; ?>&amp;asc=<?php echo $asc; ?>&amp;ipp=<?php echo $ipp; ?><?php if(isset($filter)): ?>&amp;filter=<?php echo $filter; ?>&amp;filter_id=<?php echo $filter_id; ?><?php endif; ?><?php if($data_type==1): ?>#items<?php endif; ?>" title="<?php echo $lang['next_page_title']; ?>"><span class="glyphicon glyphicon-chevron-right"></span></a></li><?php endif; ?>  
</ul>
<?php endif; ?>
</div>
</div>

<?php else: ?>
<div class="alert alert-warning"><?php echo $lang['db_table_empty']; ?></div>
<?php endif; ?>
</div>

<?php /* ############################## BEGIN IMAGES ############################## */ ?>
<?php if(isset($data_images)): ?>
<div id="images" class="mytab-pane">

<?php if(isset($images)): ?>
<div class="gallery-wrapper">
<div class="gallery"<?php if($permission['write']): ?> data-gallery-sortable="<?php echo BASE_URL; ?>?r=data_image.reorder"<?php endif; ?>>
<?php foreach($images as $image): ?>
<span id="item_<?php echo $image['id']; ?>" class="photooptions">
<a class="thumbnail" href="<?php echo $image['image_url']; ?>" title="<?php echo $image['title']; ?>" data-lightbox>
<img src="<?php echo $image['thumbnail_url']; ?>" alt="<?php echo $image['title']; ?>" title="<?php echo $image['title']; ?>" data-description="<?php echo $image['description']; ?>" data-author="<?php echo $image['author']; ?>" width="<?php echo $image['thumbnail_width']; ?>" height="<?php echo $image['thumbnail_height']; ?>">
<span><?php echo truncate($image['title'],20,true); ?></span></a>
<?php if($settings['data_images_download_original']): ?><a class="download_button<?php if($permission['write']): ?>_write<?php endif; ?> text-muted" href="<?php echo BASE_URL; ?>?r=data_image.download&amp;id=<?php echo $image['id']; ?>" title="<?php echo $lang['download_image_link']; ?>"><span class="glyphicon glyphicon-download"></span></a><?php endif; ?><?php if($permission['write']): ?><a class="edit_button" href="<?php echo BASE_URL; ?>?r=data_image.edit&amp;id=<?php echo $image['id']; ?>" title="<?php echo $lang['edit']; ?>"><span class="glyphicon glyphicon-pencil"></span></a><a class="delete_button text-danger" href="<?php echo BASE_URL; ?>?r=data_image.delete&amp;id=<?php echo $image['id']; ?>" title="<?php echo $lang['delete']; ?>" data-delete-confirm="<?php echo rawurlencode($lang['delete_data_image_message']); ?>"><span class="glyphicon glyphicon-remove"></span></a><span class="drag_button text-success" title="<?php echo $lang['drag_and_drop']; ?>"><span class="glyphicon glyphicon-move"></span></span><?php endif; ?>
</span>
<?php endforeach; ?>
</div>
</div>
<?php else: ?>
<div class="alert alert-warning"><?php echo $lang['no_data_images_available']; ?></div>
<?php endif; ?>

<?php if(!$readonly && $permission['write']): ?>
<a class="btn btn-success" href="<?php echo BASE_URL; ?>?r=data_image.add&amp;data_id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-plus-sign"></span> <?php echo $lang['add_data_image_link']; ?></a>
<?php endif; ?>


</div>
<?php endif; ?>
<?php /* ############################## END IMAGES ############################## */ ?>


<div id="properties" class="mytab-pane">

<div class="table-responsive">
<table class="table table-striped">

<tr>
<td class="key"><strong><?php echo $lang['type_label']; ?></strong></td>
<td class="value"><span class="glyphicon <?php if($data_type==1): ?>glyphicon-globe<?php else: ?>glyphicon-list<?php endif; ?>"></span> <?php echo $lang['db_table_type_label'][$data_type]; ?> <?php if($data_type==1): ?> (<?php echo $lang['db_table_geometry_type_label'][$geometry_type]; ?>)<?php endif; ?></td>
</tr>

<tr>
<td class="key"><strong><?php echo $lang['status_label']; ?></strong></td>
<td class="value"><?php echo $lang['db_table_status_label'][$table_status]; ?><?php if($readonly): ?> (<?php echo $lang['db_table_status_readonly']; ?>)<?php endif; ?></td>
</tr>

<?php if($description): ?>
<tr>
<td class="key"><strong><?php echo $lang['description_label']; ?></strong></td>
<td class="value"><?php echo $description; ?></td>
</tr>
<?php endif; ?>

<tr>
<td class="key"><strong><?php echo $lang['number_of_records_label']; ?></strong></td>
<td class="value"><?php echo $total_items; ?></td>
</tr>

<?php if(isset($spatial_info['count'])): ?>
<tr>
<td class="key"><strong><?php echo $lang['number_of_spatial_records_label']; ?></strong></td>
<td class="value"><?php echo $spatial_info['count']; ?></td>
</tr>
<?php endif; ?>


<?php if(isset($spatial_info['area']) && $spatial_info['area']['raw']>0): ?>
<tr>
<td class="key"><strong><?php echo $lang['total_area_label']; ?></strong></td>
<td class="value"><?php echo $spatial_info['area']['sqkm']; ?> km² / <?php echo $spatial_info['area']['ha']; ?> ha / <?php echo $spatial_info['area']['sqm']; ?> m²</td>
</tr>
<?php endif; ?>

</table>
</div>

<?php if($permission['manage']): ?>
<a class="btn btn-primary" href="<?php echo BASE_URL; ?>?r=data_model.edit_model&amp;id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-pencil"></span> <?php echo $lang['edit_data_model_properties_link']; ?></a>
<?php endif; ?>

</div>

<div id="structure" class="mytab-pane">

<?php if($permission['manage']): ?>
<div class="row">
<div class="col-sm-12">
<a class="btn btn-success pull-right bottom-space-small" href="<?php echo BASE_URL; ?>?r=data_model.add_item&amp;data_id=<?php echo $table_id; ?>"><span class="glyphicon glyphicon-plus"></span> <?php echo $lang['data_model_add_item_link']; ?></a>
</div>
</div>
<?php endif; ?>

<?php if(isset($columns)): ?>

<div class="table-responsive">
<table class="table table-hover">
<thead>
<tr>
<th><?php echo $lang['db_table_items_label_column_label']; ?></th>
<th><?php echo $lang['db_table_items_type_column_label']; ?></th>
<th><?php echo $lang['db_table_items_choices_column_label']; ?></th>
<th><?php echo $lang['db_table_items_required_column_label']; ?></th>
<th><?php echo $lang['db_table_items_unique_column_label']; ?></th>
<th><?php echo $lang['db_table_items_definition_column_label']; ?></th>
<!--<th><?php echo $lang['db_table_items_comments_column_label']; ?></th>-->
<?php if($permission['manage']): ?>
<th>&nbsp;</th>
<?php endif; ?>
</tr>
</thead>

<tbody data-sortable="<?php echo BASE_URL; ?>?r=data_model.reorder_items">

<?php $alter=false; $i=1; foreach($columns as $column): ?>
<?php if($column['type']==0||$column['priority']!=1) { if($alter) $alter=false; else $alter=true; } ?>
<tr id="item_<?php echo $column['id']; ?>" class="<?php if($column['type']==0): ?><?php if($column['priority']==2): ?>high-priority-section<?php elseif($column['priority']==1): ?>low-priority-section<?php if($alter): ?> alter<?php endif; ?><?php else: ?>default-priority-section<?php endif; ?><?php else: ?><?php if($column['priority']==2): ?>high-priority<?php elseif($column['priority']==1): ?>low-priority<?php else: ?>default-priority<?php endif; ?><?php if($alter): ?> alter<?php endif; ?><?php endif; ?>">
<?php if($column['type']==0): ?>
<td colspan="6"><?php if($column['label']): ?><?php echo $column['label']; ?><?php if($column['description']): ?><br /><span class="description"><?php echo $column['description']; ?></span><?php endif; ?><?php else: ?>&nbsp;<?php /*echo $column['name'];*/ ?><?php endif; ?></td>
<?php else: ?>
<td><strong><?php echo htmlspecialchars($column['label']); ?></strong>
<?php if($column['description']): ?><br /><span class="description"><?php echo htmlspecialchars($column['description']); ?></span><?php endif; ?>
</td>
<td><?php echo $column_types[$column['type']]['label']; ?> <?php if($column['relation']): ?><br /><span class="label label-warning"><span class="glyphicon glyphicon-link"></span> <?php echo htmlspecialchars($column['relation_table_title']); ?> (<?php echo htmlspecialchars($column['relation_column_label']); ?>)<?php endif; ?></td>
<td>
<?php if($column['choices']): ?>
<ul>
<?php foreach($column['choices'] as $choice): ?>
<li><?php echo $column['choice_labels'][$choice]; ?></li>
<?php endforeach; ?>
</ul>
<?php endif; ?>
</td>
<td><?php if($column['required']): ?><span class="glyphicon glyphicon-ok text-success" title="<?php echo $lang['yes']; ?>"></span><?php endif; ?></td>
<td><?php if($column['unique']): ?><span class="glyphicon glyphicon-ok text-success" title="<?php echo $lang['yes']; ?>"></span><?php endif; ?></td>
<td><?php echo nl2br(htmlspecialchars($column['definition'])); ?></td>
<!--<td><?php echo nl2br(htmlspecialchars($column['comments'])); ?></td>-->
<?php endif; ?>

<?php if($permission['manage']): ?>
<td class="options">
<a class="btn btn-primary btn-xs" href="?r=data_model.edit_item&amp;id=<?php echo $column['id']; ?>" title="<?php echo $lang['edit']; ?>"><span class="glyphicon glyphicon-pencil"></span></a>
<a class="btn btn-danger btn-xs" href="?r=data_model.delete_item&amp;id=<?php echo $column['id']; ?>" title="<?php echo $lang['delete']; ?>" data-delete-confirm="<?php echo rawurlencode($lang['delete_db_table_item_message']); ?>"><span class="glyphicon glyphicon-remove"></span></a>
<span class="btn btn-success btn-xs sortable_handle" title="<?php echo $lang['drag_and_drop']; ?>"><span class="glyphicon glyphicon-sort"></span></span>
</td>
<?php endif; ?>

</tr>
<?php ++$i; endforeach; ?>
</tbody>

</table>
</div>


<?php else: ?>

<div class="alert alert-warning top-space"><?php echo $lang['no_db_table_items_available']; ?></div>

<?php endif; ?>

</div>
</div>

<?php if($data_type==1 && empty($_SESSION[$settings['session_prefix'].'usersettings']['disable_map'])): /* spatial data - display map */ ?>
<?php if($max_resolution): ?>
<?php
$js[] = 'map.setOptions({maxResolution:'.$max_resolution.'});';
?>
<?php endif; ?>
<?php if(isset($basemaps)): ?>
<?php foreach($basemaps as $basemap): ?>
<?php
$js[] = 'var basemap_'.$basemap['id'].' = new OpenLayers.Layer.'.$basemap['properties'].'
map.addLayer(basemap_'.$basemap['id'].');
if(typeof(basemap_'.$basemap['id'].'.mapObject)!="undefined") basemap_'.$basemap['id'].'.mapObject.setTilt(0);';
?>
<?php endforeach; ?>
<?php endif; ?>

<?php
$js[] = 'navigationControl = new OpenLayers.Control.Navigation({"zoomWheelEnabled":false});
map.addControl(navigationControl);
if(document.getElementById("zoomwheel") && document.getElementById("zoomwheel").className == "active") navigationControl.enableZoomWheel();';
?>

<?php if($layer_overview && $min_scale): ?>
<?php
if($layer_overview==1) $cluster_strategy = ', new OpenLayers.Strategy.Cluster()';
else $cluster_strategy = '';
if($layer_overview==1) $overview_style = 'overviewStylePointCluster';
else $overview_style = 'overviewStyleConvexHull';
$js[] = 'overviewLayer = new OpenLayers.Layer.Vector("'.ol_encode_label($lang['layer_overview_label']).'", {
projection: projData,
strategies: [new OpenLayers.Strategy.Fixed()'.$cluster_strategy.'],
protocol: new OpenLayers.Protocol.HTTP({ url: "'.BASE_URL.'",
                                         params: { r:"json_data", table:"'.$table_id.'" },
                                         format: new OpenLayers.Format.GeoJSON() }),
                                         maxScale:'.$min_scale.',
                                         units: "m",
                                         styleMap:'.$overview_style.',
                                         displayInLayerSwitcher:false });';
?>
<?php endif; ?>
<?php if($auxiliary_layer_1): ?>
<?php
$auxiliary_layer_1_res_factor = isset($auxiliary_layer_1_redraw) ? '{resFactor:1}' : '';
$js[] = 'auxiliary_layer_1 = new OpenLayers.Layer.Vector("'.ol_encode_label($auxiliary_layer_1_title).'", {
projection: projData,        
strategies: [new OpenLayers.Strategy.BBOX('.$auxiliary_layer_1_res_factor.')],
protocol: new OpenLayers.Protocol.HTTP({ url: "'.BASE_URL.'",
                                         params: { r:"json_data", table:"'.$auxiliary_layer_1.'" },
                                         format: new OpenLayers.Format.GeoJSON() }),
    styleMap:auxiliaryLayerStyle
});
map.addLayer(auxiliary_layer_1);';
?>
<?php endif; ?>
<?php
$res_factor = isset($redraw) ? '{resFactor:1}' : '';
$min_scale_code = isset($min_scale) ? 'minScale:'.$min_scale.',' : '';
$max_scale_code = isset($max_scale) ? 'maxScale:'.$max_scale.',' : '';
$js[] = 'vectorLayer = new OpenLayers.Layer.Vector("'.ol_encode_label($subtitle).'", {
projection: projData,        
strategies: [new OpenLayers.Strategy.BBOX('.$res_factor.')],
protocol: new OpenLayers.Protocol.HTTP({ url: "'.BASE_URL.'",
                                         params: { r:"json_data", table:"'.$table_id.'", attributes:true },
                                         format: new OpenLayers.Format.GeoJSON() }),
                                         '.$min_scale_code.'
                                         '.$max_scale_code.'
                                         units: "m",
                                         styleMap:featuresStyle });';
?>
<?php if($layer_overview): ?>
<?php $js[] = 'map.addLayer(overviewLayer);'; ?>
<?php endif; ?>
<?php $js[] = 'map.addLayer(vectorLayer);'; ?>

<?php
$js[] = 'if(vectorLayer.calculateInRange()) document.getElementById("layerinactivenotice").style.display = "none";
else document.getElementById("layerinactivenotice").style.display = "block";';
?>
<?php if(isset($current_position)): ?>
<?php $js[] = 'map.setCenter(new OpenLayers.LonLat('.$current_position['longitude'].','.$current_position['latitude'].'), '.$current_position['zoomlevel'].');'; ?>
<?php elseif(isset($default_longitude) && isset($default_latitude) && isset($default_zoomlevel)): ?>
<?php
$js[] = 'map.setCenter(new OpenLayers.LonLat('.$default_longitude.','.$default_latitude.').transform(projData, projDisplay), '.$default_zoomlevel.');';
?>
<?php elseif($spatial_info['extent']): ?>
<?php $js[] = 'extentLayer = new OpenLayers.Layer.Vector("Extent");
var extent = new OpenLayers.Format.WKT({"internalProjection":projDisplay,"externalProjection":projData}).read("'.$spatial_info['extent'].'");
extentLayer.addFeatures([extent]);
map.zoomToExtent(extentLayer.getDataExtent());'; ?>
<?php else: ?>
<?php
$js[] = 'map.setCenter(new OpenLayers.LonLat('.$settings['default_longitude'].','.$settings['default_latitude'].').transform(projData, projDisplay), '.$settings['default_zoomlevel'].');'; ?>
<?php endif; ?>
<?php

if($permission['write']) $feature_options = '<p class=\"fib-options\"><a class=\"btn btn-primary btn-xs\" href=\"'.BASE_URL.'?r=edit_data_item.edit&amp;data_id='.$table_id.'&amp;id="+feature.attributes.id+"\" title=\"'.$lang['edit'].'\"><span class=\"glyphicon glyphicon-pencil\"></span></a>&nbsp;<a class=\"btn btn-danger btn-xs\" href=\"'.BASE_URL.'?r=data.delete&amp;data_id='.$table_id.'&amp;id="+feature.attributes.id+"\" onclick=\"return delete_confirm(this, \''.rawurlencode($lang['delete_data_item_message']).'\')\" title=\"'.$lang['delete'].'\"><span class=\"glyphicon glyphicon-remove\"></span></a></p>';
else $feature_options = '';

$feature_info = '<p>"+featureInfo(feature.attributes.area, feature.attributes.perimeter, feature.attributes.length, feature.attributes.latitude, feature.attributes.longitude)+"</p>';

$js[] = 'map.addControl(new OpenLayers.Control.LayerSwitcher());
vectorLayer.events.on({
featureselected: function(event) {
var feature = event.feature;
feature.popup = new OpenLayers.Popup.FramedCloud("pop",feature.geometry.getBounds().getCenterLonLat(),null,"<div class=\"featureinfobubble\"><p><a href=\"'.BASE_URL.'?r=data_item&data_id='.$table_id.'&id="+feature.attributes.id+"\"><strong>"+decodeURIComponent(feature.attributes.label)+"</strong></a></p>'.$feature_info.$feature_options.'</div>",null,true);
map.addPopup(feature.popup);},
featureunselected: function(event) {
var feature = event.feature;
map.removePopup(feature.popup);
feature.popup.destroy();
feature.popup = null;
}});

selectControl = new OpenLayers.Control.SelectFeature( [ vectorLayer ], { clickout:true, toggle:true, multiple:false, hover:false } );
map.addControl(selectControl);
selectControl.activate();
if(typeof(selectControl.handlers) != "undefined") selectControl.handlers.feature.stopDown = false;';
?>  
<?php endif; ?>
