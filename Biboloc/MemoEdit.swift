//
//  MemoCreate.swift
//  Biboloc
//
//  Created by awa on 2023/07/22.
//

import SwiftUI

struct MemoEdit: View {
    enum Field: Hashable {
        case memo
        case tag
    }
    
    @Binding var is_New: Bool
    @Binding var is_Display_MemoEdit: Bool
    @Binding var memo: Memo
    @ObservedObject var database: Database
    @FocusState var focusedField: Field?
    
    @State private var NewTag = ""
    
    var body: some View {
        ZStack {
            
            
            if (focusedField != nil) == true {
                Button(action: {
                    focusedField = nil
                }) {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 320, height: 440)
                        .padding()
                }
            }
            VStack {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            
                            DatePicker(
                                "",
                                selection: $memo.created_at,
                                displayedComponents: [.hourAndMinute, .date]
                            )
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .labelsHidden()
                            
                            Spacer()
                        }
                    }
                    VStack {
                        // 閉じるボタン
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    focusedField = nil
                                    is_Display_MemoEdit = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                                    .font(Font.system(size: 20))
                            }
                        }
                        Spacer()
                    }
                }.frame(height: 40)
                
                ZStack {
                    TextEditor(text: $memo.text)
                        .focused($focusedField, equals: .memo)
                    
                    
                    Button(action: {
                        focusedField = nil
                    }) {
                        Rectangle()
                            .fill(.clear)
                            .padding()
                    }
                }
                    
                    Spacer()
                
                
                VStack {
                    ScrollView (.horizontal, showsIndicators: false){
                        HStack {
                            // タグ追加
                            TextField("#", text: $NewTag)
                                .foregroundColor(.white)
                                .accentColor(.white)
                                .padding(10)
                                .background(Color.gray.opacity(0.4))
                                .frame(width: 100,height: 30)
                                .cornerRadius(15)
                                .focused($focusedField, equals: .tag)
                                .bold()
                            
                            Button(action: {
                                if NewTag != "" {
                                    if (IndexTag(TagList: database.TagList, name: NewTag) == -1) {
                                        database.createTag(tag: Tag(name: NewTag, used_at: Date(), deleted: false))
                                    } else {
                                        database.TagList[IndexTag(TagList: database.TagList, name: NewTag)].used_at = Date()
                                        database.updateTag()
                                    }
                                    
                                    if (IndexTag(TagList: memo.tag, name: NewTag) == -1) {
                                        memo.tag.append(Tag(name: NewTag, used_at: Date(), deleted: false))
                                        database.updateMemo()
                                    }
                                    NewTag = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(Color.MainColor)
                                    .font(.system(size: 30, weight: .bold, design: .serif))
                                    .frame(width: 30,height: 30)
                            }
                            ForEach(database.TagList, id: \.self) { tag in
                                
                                if (IndexTag(TagList: memo.tag, name: tag.name) != -1) {
                                    Button(action: {
                                        if (IndexTag(TagList: memo.tag, name: tag.name) != -1) {
                                            memo.tag.remove(at: IndexTag(TagList: memo.tag, name: tag.name))
                                            database.updateMemo()
                                        }
                                    }) {
                                        Text("# \(tag.name)")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .bold()
                                            .frame(height: 30)
                                            .background(Color.BaseColor.opacity(0.7))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                            ForEach(database.TagList, id: \.self) { tag in
                                
                                if (IndexTag(TagList: memo.tag, name: tag.name) == -1) {
                                    Button(action: {
                                        memo.tag.append(tag)
                                        tag.used_at = Date()
                                        database.updateMemo()
                                        database.updateTag()
                                    }) {
                                        Text("# \(tag.name)")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .bold()
                                            .frame(height: 30)
                                            .background(Color.gray.opacity(0.4))
                                            .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                }.frame(height: 40)
                
                VStack {
                    if !is_New {
                        HStack {
                            Button(action: {
                                focusedField = nil
                                is_Display_MemoEdit = false
                                database.deleteMemo(memo: memo)
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 30, weight: .bold, design: .serif))
                                    .frame(width: 30, height: 30)
                            }
                            
                            Button(action: {
                                focusedField = nil
                                is_Display_MemoEdit = false
                                if is_New {
                                    database.createMemo(
                                        memo: memo
                                    )
                                } else {
                                    database.updateMemo()
                                }
                                if NewTag != "" {
                                    if (IndexTag(TagList: database.TagList, name: NewTag) == -1) {
                                        database.createTag(tag: Tag(name: NewTag, used_at: Date(), deleted: false))
                                    } else {
                                        database.TagList[IndexTag(TagList: database.TagList, name: NewTag)].used_at = Date()
                                        database.updateTag()
                                    }
                                    
                                    if (IndexTag(TagList: memo.tag, name: NewTag) == -1) {
                                        memo.tag.append(Tag(name: NewTag, used_at: Date(), deleted: false))
                                        database.updateMemo()
                                    }
                                    NewTag = ""
                                }
                            }) {
                                Text("登録")
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .frame(width: 240, height: 40)
                                    .bold()
                                    .background(Color.BaseColor)
                                    .cornerRadius(20)
                            }
                            if memo.favorite {
                                Button(action: {
                                    memo.favorite = false
                                    database.updateMemo()
                                }) {
                                    
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(Color.MainColor)
                                        .font(.system(size: 30, weight: .bold, design: .serif))
                                        .frame(width: 30, height: 30)
                                }
                            } else {
                                Button(action: {
                                    memo.favorite = true
                                    database.updateMemo()
                                }) {
                                    
                                    Image(systemName: "star.circle.fill")
                                        .foregroundColor(Color.gray.opacity(0.5))
                                        .font(.system(size: 30, weight: .bold, design: .serif))
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                    } else {
                        Button(action: {
                            focusedField = nil
                            is_Display_MemoEdit = false
                            if is_New {
                                database.createMemo(
                                    memo: memo
                                )
                            } else {
                                database.updateMemo()
                            }
                            if NewTag != "" {
                                if (IndexTag(TagList: database.TagList, name: NewTag) == -1) {
                                    database.createTag(tag: Tag(name: NewTag, used_at: Date(), deleted: false))
                                } else {
                                    database.TagList[IndexTag(TagList: database.TagList, name: NewTag)].used_at = Date()
                                    database.updateTag()
                                }
                                
                                if (IndexTag(TagList: memo.tag, name: NewTag) == -1) {
                                    memo.tag.append(Tag(name: NewTag, used_at: Date(), deleted: false))
                                    database.updateMemo()
                                }
                                NewTag = ""
                            }
                        }) {
                            Text("登録")
                                .foregroundColor(.white)
                                .padding(5)
                                .frame(width: 240, height: 40)
                                .bold()
                                .background(Color.BaseColor)
                                .cornerRadius(20)
                            
                        }
                    }
                }
                .frame(height: 50)
                
            }
            .frame(width: 320, height: 440)
            .padding()
            .scaledToFit()
            .background(.white)
        }
    }
}

func IndexTag(TagList: [Tag], name: String) -> Int {
    if let num = TagList.firstIndex(where: {
        $0.name == name
    }) {
        return num
    }
    return -1
}
