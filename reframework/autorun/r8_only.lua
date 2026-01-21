local rate = sdk.get_managed_singleton("app.VariousDataManager")._Setting._RandomAmuletGradeTable._Values:get_Item(0)._Rate
rate:set_Item(0, 30)
rate:set_Item(1, 30)
rate:set_Item(2, 20)
rate:set_Item(3, 20)